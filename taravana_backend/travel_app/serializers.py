from rest_framework import serializers
from .models import *
from django.contrib.auth import get_user_model
from djoser.serializers import UserCreateSerializer as DjoserUserCreateSerializer
from djoser.serializers import UserSerializer as DjoserUserSerializer
User = get_user_model()

# 1. Бүртгэлийн Serializer (Register)
class UserCreateSerializer(DjoserUserCreateSerializer):
    re_password = serializers.CharField(write_only=True)

    class Meta(DjoserUserCreateSerializer.Meta):
        model = User
        fields = ('id', 'email', 'password', 're_password')

    def validate(self, attrs):
        if attrs['password'] != attrs['re_password']:
            raise serializers.ValidationError("Password do not match!")
        return attrs

    def create(self, validated_data):
        validated_data.pop('re_password') 
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            role='user',
            is_active=True  
        )
        return user

class ProfileSerialezer(serializers.ModelSerializer):
    profile_img = serializers.ImageField(required=False)
    profile_img_url = serializers.SerializerMethodField()  
    username = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = Profile
        fields = ('bio', 'profile_img', 'profile_img_url', 'phone', 'address','username')

    def get_profile_img_url(self, obj):
        request = self.context.get('request')
        if obj.profile_img:
            if request:
                return request.build_absolute_uri(obj.profile_img.url)
            return obj.profile_img.url
        return None

# 2. User-ийн мэдээллийг харуулах Serializer
class UserSerializer(DjoserUserSerializer):
    profile = ProfileSerialezer(read_only=True)
    class Meta(DjoserUserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'first_name', 'last_name','role', 'profile')

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

class BlogImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogImage
        fields = ['image']


class BlogSerializer(serializers.ModelSerializer):
    likes_count = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    user = UserSerializer(read_only=True)
    images = BlogImageSerializer(source='blog_image', many = True, read_only =True)

    class Meta:
        model = Blog 
        fields = ['id', 'user', 'place', 'content', 'images', 'created_at', 'is_public','likes_count',
            'is_liked',]

    def get_likes_count(self, obj):
        return obj.likes.count()

    def get_is_liked(self, obj):
        user = self.context['request'].user
        return obj.likes.filter(user=user).exists()




        