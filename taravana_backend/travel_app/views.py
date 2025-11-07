from django.shortcuts import render
from rest_framework import viewsets
from .models import Country
from .serializer import CountrySerializer

# Create your views here.
class CountryViewSet(viewsets.ModelViewSet):
    queryset = Country.objects.all()
    serializer_class = CountrySerializer
