from rest_framework import serializers
from .models import Country, Place, Trip
from django.contrib.auth import get_user_model
from djoser.serializers import UserCreateSerializer 
from djoser.serializers import UserSerializer 
User = get_user_model()



# 1. Бүртгэлийн Serializer (Register)
class UserCreateSerializer(UserCreateSerializer):
    class Meta(UserCreateSerializer.Meta):
        model = User
        fields = ('id', 'username', 'email', 'password','role')

    def create(self, validated_data):
        user = super().create(validated_data)
        if validated_data.get('role') == 'admin':
            user.is_staff = True
            user.is_superuser = True
            user.save()
        return user

# 2. User-ийн мэдээллийг харуулах Serializer
class UserSerializer(UserSerializer):
    class Meta(UserSerializer.Meta):
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name','role')

class CountrySerializer(serializers.ModelSerializer):
    class Meta:
        model = Country
        fields = '__all__'
class PlaceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Place
        fields = '__all__'
class TripSerializer(serializers.ModelSerializer):
    # place_name = serializers.CharField(source = 'place_name', read_only = True)
    class Meta:
        model = Trip
        fields = '__all__'
       
        