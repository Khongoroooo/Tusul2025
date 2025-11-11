# travel_app/permissions.py (Өөрчлөлтгүйгээр ажиллана)

from rest_framework import permissions

class IsOwnerOrAdmin(permissions.BasePermission):
    
    def has_object_permission(self, request, view, obj):
        
        # 1. Унших (GET, HEAD, OPTIONS) хүсэлтүүдийг бүгдэд зөвшөөрнө.
        if request.method in permissions.SAFE_METHODS:
            return True
            
        # 2. Admin эрх: request.user.role == 'admin'
        if request.user.role == 'admin':
            return True # Admin бол бүх Trip дээр үйлдэл хийх эрхтэй (CRUD)

        # 3. Эзэмшигчийн эрх: obj.user == request.user
        return obj.user == request.user