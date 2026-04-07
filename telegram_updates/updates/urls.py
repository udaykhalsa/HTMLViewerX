from django.urls import path
from .views import SendToTelegramView

urlpatterns = [
    path('send-to-telegram/', SendToTelegramView.as_view(), name='send_to_telegram'),
]