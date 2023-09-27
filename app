from flask import Flask, render_template, request, send_file
import cv2
import pytesseract

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
def recognize_text(image_path):
    # Загрузка изображения с использованием OpenCV
    img = cv2.imread(image_path)

    # Преобразование изображения в оттенки серого
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Применение преобразования порогового значения для бинаризации изображения
    _, threshold = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)

    # Применение OCR с помощью pytesseract и получение распознанного текста
    recognized_text = pytesseract.image_to_string(threshold, lang='rus+eng')

    return recognized_text

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        # Получение загруженного изображения
        image = request.files['image']
        image_path = f"uploads/{image.filename}"
        image.save(image_path)

        # Распознавание текста на изображении
        text = recognize_text(image_path)

        # Сохранение распознанного текста в файл
        output_filename = "recognized_text.txt"
        with open(output_filename, "w") as file:
            file.write(text)

        # Отправка файла пользователю для скачивания
        return send_file(output_filename, as_attachment=True)

    return render_template('index.html')

if __name__ == '__main__':
    app.run()
