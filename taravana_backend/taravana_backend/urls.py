"""
URL configuration for taravana_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from travel_app.views import *
from django.conf.urls.static import static
from rest_framework import routers

from rest_framework_simplejwt.views import (TokenObtainPairView, TokenRefreshView)

from django.conf import settings

router = routers.DefaultRouter()
router.register(r'countries',CountryViewSet)
router.register(r'places',PlaceViewSet)
router.register(r'trips',TripViewSet, basename='trip')
router.register(r'blogs',BlogViewSet, basename='blog')




urlpatterns = [
    path("admin/", admin.site.urls),    
    path('auth/', include('djoser.urls')),
    # 2. Djoser-ийн JWT Login/Logout
    path('auth/', include('djoser.urls.jwt')),
    # 3. DRF Simple JWT-ийн Token-уудыг шууд ашиглах (Нэвтрэх, Сэргээх)
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/', include(router.urls)),
    path('api/me/', get_me, name='me'),
    path('api/add_comment/<int:blog_id>', add_comment, name='comment'),
    path('api/profile/update/', update_profile, name='update_profile'),
    path('api/blogs/<int:blog_id>/like/', toggle_like, name='blog_like'),
    path('api/comments/<int:comment_id>/delete/', delete_comment),
    path('api/blogs/<int:blog_id>/save/', toggle_save, name='toggle-save'),
    path('api/saved_blogs/', saved_blogs, name='saved_blogs'),
    path('api/blogs/<int:blog_id>/delete/', delete_blog, name='delete_blog'),





    
  
]

  


if settings.DEBUG:
    urlpatterns +=static(settings.MEDIA_URL, document_root = settings.MEDIA_ROOT)
