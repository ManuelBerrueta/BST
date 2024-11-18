import pytesseract
from PIL import Image, ImageGrab
import pyperclip
import subprocess
import io
import platform
import argparse

def extract_text_from_clipboard_image_linux():
    clipboard_data = subprocess.run(['xclip', '-selection', 'clipboard', '-t', 'image/png', '-o'], stdout=subprocess.PIPE)
    
    if clipboard_data.returncode == 0:
        image_data = clipboard_data.stdout
        image = Image.open(io.BytesIO(image_data))
        text = pytesseract.image_to_string(image)
        return text
    else:
        return "No image found in clipboard."

def extract_text_from_clipboard_image_windows_macos():
    image = ImageGrab.grabclipboard()
    
    if isinstance(image, Image.Image):
        text = pytesseract.image_to_string(image)
        return text
    else:
        return "No image found in clipboard."

def extract_text_from_clipboard_image():
    os_name = platform.system()
    if os_name == "Linux":
        return extract_text_from_clipboard_image_linux()
    elif os_name in ["Windows", "Darwin"]:
        return extract_text_from_clipboard_image_windows_macos()
    else:
        return "Unsupported operating system."

def extract_text_from_image_file(image_path):
    image = Image.open(image_path)
    text = pytesseract.image_to_string(image)
    return text

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract text from an image using OCR.")
    parser.add_argument('-i', '--image', type=str, help="Path to the image file.")
    args = parser.parse_args()

    if args.image:
        extracted_text = extract_text_from_image_file(args.image)
    else:
        extracted_text = extract_text_from_clipboard_image()

    if extracted_text:
        print("Extracted Text:")
        print(extracted_text)
        pyperclip.copy(extracted_text)
    else:
        print("No text extracted.")