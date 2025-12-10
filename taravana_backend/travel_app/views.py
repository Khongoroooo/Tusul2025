from django.db.models import Q
from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from .models import *
from .serializers import *
from .permissions import IsOwnerOrAdmin

# GET USER
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_me(request):
    user = request.user
    blogCount = Blog.objects.filter(user=user).count()
    tripCount = Trip.objects.filter(user=user).count()
    serializers = UserSerializer(user)
    response_data = serializers.data
    response_data["blog_count"] = blogCount
    response_data["trip_count"] = tripCount
    return Response(response_data)

@api_view(['PATCH', 'PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    profile, created = Profile.objects.get_or_create(user=request.user)

    serializer = ProfileSerialezer(
        profile,
        data=request.data,  # request.FILES-ийг дамжуулж байна
        partial=True,
        context={'request': request}
    )

    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=400)

 
# Country
class CountryViewSet(viewsets.ModelViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'description']

# Place
class PlaceViewSet(viewsets.ModelViewSet):
    queryset = Place.objects.all()
    serializer_class = PlaceSerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'country', 'description', 'tags']
    
# Blog
class BlogViewSet(viewsets.ModelViewSet):
    queryset = Blog.objects.all()
    serializer_class = BlogSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['place', 'title', 'content','created_at']

    def get_queryset(self):
        user = self.request.user
        user_id = self.request.query_params.get('user_id')
        qs = Blog.objects.select_related("user", "user__profile")
        if user_id:
            return qs.filter(user_id=user_id).order_by('-created_at')
        return qs.filter(is_public=True).exclude(user=user).order_by('-created_at')

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context.update({"request": self.request})
        return context

    def perform_create(self, serializer):
        blog = serializer.save(user=self.request.user)
        images = self.request.FILES.getlist('images')
        for img in images:
            BlogImage.objects.create(blog=blog, image=img)

      

# Trip
class TripViewSet(viewsets.ModelViewSet):
    serializer_class = TripSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter]
    search_fields = ['title', 'place__name', 'notes', 'budget', 'start_date', 'end_date']

    def get_queryset(self):
        # Зөвхөн тухайн хэрэглэгчийн trip-үүдийг авна
        queryset = Trip.objects.filter(user=self.request.user).order_by('-created_at')

        # Search query
        search = self.request.query_params.get('search', '')
        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) |
                Q(place__name__icontains=search) |
                Q(notes__icontains=search)
            )

        # Status filter
        status = self.request.query_params.get('status', None)
        if status:
            queryset = queryset.filter(status=status)

        return queryset

    def perform_create(self, serializer):
        # Trip үүсгэх үед user-г автоматаар онооно
        serializer.save(user=self.request.user)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_like(request, blog_id):
    user = request.user
    try:
        blog = Blog.objects.get(id=blog_id)
    except Blog.DoesNotExist:
        return Response({"ERROR":"Blog not found"}, status=400)

    like = Like.objects.filter(blog=blog, user=user).first()
    
    if like:
        like.delete()
        liked = False
    else:
        Like.objects.create(blog=blog, user=user)
        liked = True

    likes_count = blog.likes.count()  # like тоо
    return Response({
        "message": "liked" if liked else "unliked",
        "liked": liked,
        "likes_count": likes_count
    })

