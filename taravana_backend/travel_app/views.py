from django.shortcuts import render
from rest_framework import viewsets, generics, filters
from .models import Country, Place,Trip
from .serializer import CountrySerializer,PlaceSerializer,TripSerializer
from .permissions import IsOwnerOrAdmin
from rest_framework.permissions import IsAuthenticated
from rest_framework.permissions import AllowAny

# class TripViewSet(viewsets.ModelViewSet):
#     # 1. Queryset: API-д харуулах бүх өгөгдөл.
#     queryset = Trip.objects.all().order_by('-created_at') 
    
#     # 2. Serializer:
#     serializer_class = TripSerializer
    
#     # 3. Permission:
#     permission_classes = [IsAuthenticated, IsOwnerOrAdmin] 
    
#     # 4. Create (POST) хийх үед хэрэглэгчийг автоматаар оноох функц
#     def perform_create(self, serializer):
#         # request.user нь Token-оос ирсэн CustomUser объект байна
#         serializer.save(user=self.request.user)
# Create your views here.
class CountryViewSet(viewsets.ModelViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'description']
class PlaceViewSet(viewsets.ModelViewSet):
    queryset = Place.objects.all()
    serializer_class = PlaceSerializer
    filter_backends = [filters.SearchFilter]
    permission_classes = [AllowAny]
    search_fields = ['name', 'country', 'description', 'tags']
from django.db.models import Q

class TripViewSet(viewsets.ModelViewSet):
    queryset = Trip.objects.all().order_by('-created_at')  # 👈 Шинэ нь эхэнд
    serializer_class = TripSerializer
    permission_classes = [AllowAny]
    filter_backends = [filters.SearchFilter]
    search_fields = ['title','place__name','notes','budget','start_date','end_date']

    def get_queryset(self):
        queryset = super().get_queryset()
        search = self.request.query_params.get('search', '')
        status = self.request.query_params.get('status', None)

        if search:
            queryset = queryset.filter(
                Q(title__icontains=search) |
                Q(place__name__icontains=search) |
                Q(notes__icontains=search)
            )

        if status:
            queryset = queryset.filter(status=status)

        return queryset.order_by('-created_at')  # 👈 Шинэ нь эхэнд
