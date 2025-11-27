from django.db import models
from django.contrib.auth.models import User, AbstractUser
from django.contrib.auth import get_user_model
from django.utils import timezone

from django.contrib.auth.models import BaseUserManager, AbstractUser
from django.db import models

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")

        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        return self.create_user(email, password, **extra_fields)


class CustomUser(AbstractUser):
    ROLE_CHOICES = (
        ('user', 'User'),
        ('admin', 'Admin'),
    )

    username = None  # username-г хассан
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='user')

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = CustomUserManager()  # 💥 ШИНЭ MANAGER АШИГЛАНА

    def __str__(self):
        return self.email



# --------------------------
# Country
# --------------------------
class Country(models.Model):
    name = models.CharField(max_length=150)
    description = models.TextField()
    image = models.ImageField(upload_to='countries/',blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
    
# --------------------------
# Profile
# --------------------------

class Profile(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    bio = models.TextField()
    phone = models.IntegerField(blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=100, blank=True, null=True)
    First_name = models.CharField(max_length=100, blank=True, null=True)


# --------------------------
# Badge
# --------------------------
class Badge(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon = models.CharField(max_length=255)
    condition = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

# --------------------------
# Place
# --------------------------
class Place(models.Model):
    country = models.ForeignKey(Country, on_delete=models.CASCADE, related_name='places')
    name = models.CharField(max_length=150)
    description = models.TextField()
    image = models.ImageField(upload_to='place/', blank=True, null=True)
    tags = models.CharField(max_length=255, blank=True, null=True)
    priority = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

# --------------------------
# Blog
# --------------------------
class Blog(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='blogs')
    country = models.ForeignKey(Country, on_delete=models.CASCADE, related_name='blogs')
    title = models.CharField(max_length=255)
    content = models.TextField()
    image = models.ImageField(upload_to='blog/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title

# --------------------------
# Like
# --------------------------
class Like(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='likes')
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE, related_name='likes')
    created_at = models.DateTimeField(auto_now_add=True)

# --------------------------
# UserBadge (many-to-many through)
# --------------------------
class UserBadge(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='user_badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE, related_name='user_badges')
    date_awarded = models.DateTimeField(auto_now_add=True)

# --------------------------
# Trip
# --------------------------
class Trip(models.Model):
    STATUS_CHOICES = (
        ('planned', 'planned'),
        ('completed', 'completed'),
    )

    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='trips',blank=True, null=True)
    place = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='trips')
    start_date = models.DateField()
    title = models.CharField(max_length=100, blank=False, null=False)
    end_date = models.DateField()
    budget = models.IntegerField(blank=True, null=True)
    image = models.ImageField(upload_to='trips/', blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='planned')
    def save(self, *args, **kwargs):
        today  = timezone.now().date()
        if self.end_date < today:
            self.status = 'completed'
        else:
            self.status = 'planned'

        super().save(*args, **kwargs)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

# --------------------------
# Comment
# --------------------------
class Comment(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='comments')
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE, related_name='comments')
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'Comment by {self.user.email} on {self.blog.title}'
