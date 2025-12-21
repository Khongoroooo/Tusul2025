from rest_framework import serializers
from .models import *
from django.contrib.auth import get_user_model
from djoser.serializers import UserCreateSerializer as DjoserUserCreateSerializer
from djoser.serializers import UserSerializer as DjoserUserSerializer

User = get_user_model()

# -----------------------------
# User Create Serializer
# -----------------------------
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

# -----------------------------
# Profile Serializer
# -----------------------------
class ProfileSerializer(serializers.ModelSerializer):
    profile_img_url = serializers.SerializerMethodField()

    class Meta:
        model = Profile
        fields = ('username', 'bio', 'profile_img', 'profile_img_url', 'phone', 'address')

    def get_profile_img_url(self, obj):
        request = self.context.get('request')
        if obj.profile_img:
            if request:
                return request.build_absolute_uri(obj.profile_img.url)
            return obj.profile_img.url
        return None

# -----------------------------
# User Serializer
# -----------------------------
class UserSerializer(DjoserUserSerializer):
    profile = ProfileSerializer(read_only=True)

    class Meta(DjoserUserSerializer.Meta):
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'role', 'profile')

# -----------------------------
# Country / Place / Trip
# -----------------------------
class CountrySerializer(serializers.ModelSerializer):
    class Meta:
        model = Country
        fields = '__all__'

class PlaceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Place
        fields = '__all__'

class TripSerializer(serializers.ModelSerializer):
    class Meta:
        model = Trip
        fields = '__all__'

# -----------------------------
# BlogImage Serializer
# -----------------------------
class BlogImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlogImage
        fields = ['image']

# -----------------------------
# Comment Serializer
# -----------------------------
class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ['id', 'user', 'content', 'created_at']

# -----------------------------
# Blog Serializer
# -----------------------------
class BlogSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    images = BlogImageSerializer(source='blog_image', many=True, read_only=True)
    comments = CommentSerializer(many=True, read_only=True)
    comment_count = serializers.SerializerMethodField()
    likes_count = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()

    class Meta:
        model = Blog
        fields = ['id', 'user', 'place', 'content', 'images', 'created_at', 'is_public',
                  'likes_count', 'is_liked', 'is_saved', 'comment_count', 'comments']

    def get_likes_count(self, obj):
        return obj.likes.count()  # Blog -> Like relation (related_name='likes')

    def get_is_liked(self, obj):
        user = self.context['request'].user
        return obj.likes.filter(user=user).exists()

    def get_is_saved(self, obj):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            return obj.saves.filter(user=request.user).exists()  # Blog -> Save relation (related_name='saves')
        return False

    def get_comment_count(self, obj):
        return obj.comments.count()

# -----------------------------
# Save Serializer
# -----------------------------
class SaveSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    blog = BlogSerializer(read_only=True)

    class Meta:
        model = Save
        fields = ['id', 'user', 'blog', 'created_at']

# -----------------------------
# Like Serializer
# -----------------------------
class LikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    blog = BlogSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ['id', 'user', 'blog', 'created_at']
