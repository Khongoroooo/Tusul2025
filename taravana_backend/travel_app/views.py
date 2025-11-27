from django.db.models import Q
from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Country, Place, Trip
from .serializers import CountrySerializer, PlaceSerializer, TripSerializer
from .permissions import IsOwnerOrAdmin

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
