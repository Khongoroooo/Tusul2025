from django.db import models
from django.contrib.auth.models import User, AbstractUser
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.dispatch import receiver
from django.db.models.signals import post_save
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

@receiver(post_save, sender=CustomUser)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        Profile.objects.create(user=instance)

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
    username = models.CharField(max_length=100, blank=True, null=True, unique=True)
    bio = models.TextField()
    profile_img = models.ImageField(upload_to='profile/', blank=True, null=True)
    phone = models.IntegerField(blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=100, blank=True, null=True)
    First_name = models.CharField(max_length=100, blank=True, null=True)


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
    place = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='blogs', blank=True, null=True)
    content = models.TextField()
    is_public = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.content
    
class BlogImage(models.Model):
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE, related_name='blog_image')
    image = models.ImageField(upload_to='blog/', blank=True, null=True)


# --------------------------
# Like
# --------------------------
class Like(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='likes')
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE, related_name='likes')
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        unique_together = ('blog', 'user')


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

class Save(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    blog = models.ForeignKey(Blog, on_delete=models.CASCADE, related_name='saves')
    created_at = models.DateTimeField(auto_now_add=True)
    class Meta:
        unique_together = ('user', 'blog')