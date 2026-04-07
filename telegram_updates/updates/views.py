import asyncio
from telegram import Bot
from telegram.error import TelegramError, InvalidToken, BadRequest, NetworkError

from django.conf import settings

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status


async def _send_file_to_telegram(file_bytes, filename):
    """
    Async helper to send the physical file to the Telegram group.
    """
    bot = Bot(token=settings.TELEGRAM_BOT_TOKEN)
    chat_id = settings.TELEGRAM_CRON_REPORT_CHAT_ID

    if filename.lower().endswith('.pdf'):
        await bot.send_document(
            chat_id=chat_id,
            document=file_bytes,
            filename=filename,
            caption="📄 New PDF Export from HTML Studio"
        )
    else:
        await bot.send_photo(
            chat_id=chat_id,
            photo=file_bytes,
            caption="🖼️ New PNG Export from HTML Studio"
        )


class SendToTelegramView(APIView):

    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        uploaded_file = request.FILES.get('file')

        if not uploaded_file:
            print("Upload failed: No file provided in the request.")
            return Response(
                {
                    'success': False,
                    'error': 'Bad Request',
                    'message': 'No file was provided in the request.'
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        try:

            file_bytes = uploaded_file.read()
            filename = uploaded_file.name

            asyncio.run(_send_file_to_telegram(file_bytes, filename))

            print(f"Successfully sent {filename} to Telegram.")
            return Response(
                {
                    'success': True,
                    'message': f'Successfully sent {filename} to Telegram!'
                },
                status=status.HTTP_200_OK
            )

        except InvalidToken as e:
            print(f"Telegram Bot Token is invalid: {e}")
            return Response(
                {
                    'success': False,
                    'error': 'Configuration Error',
                    'message': 'Invalid Telegram bot token configured on the server.'
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        except BadRequest as e:

            print(f"Telegram Bad Request: {e}")
            return Response(
                {
                    'success': False,
                    'error': 'Telegram API Error',
                    'message': f'Failed to send to Telegram. Reason: {str(e)}'
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        except NetworkError as e:
            print(f"Telegram Network Error: {e}")
            return Response(
                {
                    'success': False,
                    'error': 'Network Error',
                    'message': 'Backend server encountered a network issue while reaching Telegram.'
                },
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )

        except TelegramError as e:
            print(f"General Telegram Error: {e}")
            return Response(
                {
                    'success': False,
                    'error': 'Telegram API Error',
                    'message': f'Telegram service error: {str(e)}'
                },
                status=status.HTTP_502_BAD_GATEWAY
            )

        except Exception as e:
            print(f"Unexpected error while processing upload: {e}")
            return Response(
                {
                    'success': False,
                    'error': 'Internal Server Error',
                    'message': 'An unexpected error occurred while processing your request.'
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR

            )
