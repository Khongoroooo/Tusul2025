from django.shortcuts import render
from rest_framework import viewsets
from .models import Country, Place,Trip
from .serializer import CountrySerializer,PlaceSerializer,TripSerializer
from .permissions import IsOwnerOrAdmin
from rest_framework.permissions import IsAuthenticated

class TripViewSet(viewsets.ModelViewSet):
    # 1. Queryset: API-д харуулах бүх өгөгдөл.
    queryset = Trip.objects.all().order_by('-created_at') 
    
    # 2. Serializer:
    serializer_class = TripSerializer
    
    # 3. Permission:
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin] 
    
    # 4. Create (POST) хийх үед хэрэглэгчийг автоматаар оноох функц
    def perform_create(self, serializer):
        # request.user нь Token-оос ирсэн CustomUser объект байна
        serializer.save(user=self.request.user)
# Create your views here.
class CountryViewSet(viewsets.ModelViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
class PlaceViewSet(viewsets.ModelViewSet):
    queryset = Place.objects.all()
    serializer_class = PlaceSerializer
class TripViewSet(viewsets.ModelViewSet):
    queryset = Trip.objects.all()
    serializer_class = TripSerializer
