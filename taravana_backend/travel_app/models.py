from django.db import models
from django.contrib.auth.models import User, AbstractUser
from django.contrib.auth import get_user_model

class CustomUser(AbstractUser):
    ROLE_CHOICES = (
        ('user', 'User'),
        ('admin', 'Admin'),

    )
    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='user',
        null=False,
        blank=False
    )
    class Meta(AbstractUser.Meta):
        swappable = 'AUTH_USER_MODEL'
    def __str__(self):
        return self.username


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
        ('planned', 'Planned'),
        ('completed', 'Completed'),
    )

    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='trips')
    place = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='trips')
    start_date = models.DateField()
    end_date = models.DateField()
    image = models.ImageField(upload_to='trips/', blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='planned')
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

class Goals(models.Model):
    pass
