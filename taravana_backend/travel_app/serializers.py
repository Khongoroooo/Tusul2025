from rest_framework import serializers
from .models import Country, Place, Trip
from django.contrib.auth import get_user_model
from djoser.serializers import UserCreateSerializer 
from djoser.serializers import UserSerializer 
User = get_user_model()



# 1. Бүртгэлийн Serializer (Register)
class UserCreateSerializer(UserCreateSerializer):
    re_password = serializers.CharField(write_only=True)

    class Meta(UserCreateSerializer.Meta):
        model = User
        fields = ('id', 'email', 'password', 're_password')

    def validate(self, attrs):
        if attrs['password'] != attrs['re_password']:
            raise serializers.ValidationError("Password do not match!")
        return attrs

    def create(self, validated_data):
        validated_data.pop('re_password')  # устгана
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            role='user',
            is_active=True  
        )
        return user


    
# 2. User-ийн мэдээллийг харуулах Serializer
class UserSerializer(UserSerializer):
    class Meta(UserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'first_name', 'last_name','role')

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
       
        