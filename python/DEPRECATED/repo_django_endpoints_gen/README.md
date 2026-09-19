# repo_endpoints_gen

Генератор Django endpoints из OpenAPI спецификации

## Описание

Модуль генерирует Django Views и URL конфигурации на основе OpenAPI спецификации (openapi.yaml). 
Генерируемые Views могут быть как базовыми заглушками, так и полнофункциональными представлениями 
с поддержкой моделей и сериализаторов Django.

## Использование

1. Поместите файл `openapi.yaml` в директорию `python/packages/django_endpoints/src/django_endpoints/`
2. Запустите генератор: `python -m repo_endpoints_gen`
3. Сгенерированные Views будут размещены в `python/packages/django_endpoints/src/django_endpoints/views/`
4. URL конфигурация будет обновлена в `python/packages/django_endpoints/src/django_endpoints/urls.py`

## Поддерживаемые параметры OpenAPI

Для генерации полнофункциональных Views необходимо указывать следующие расширения в спецификации:

### x-django-model
Указывает на Django модель, которая будет использоваться во View.
Формат: `путь.к.модули.Модель` или просто `Модель` (если модель в стандартном месте)

Пример:
