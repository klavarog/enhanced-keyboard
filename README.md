# Enhanced Keyboard - программа для улучшения раскладки клавиатуры

Это программа, которая отслеживает все ваши нажатия в реальном времени, и на основе них и той раскладки, которую вы настроете, посылает другие клавиши. Таким образом, можно поменять некоторые клавиши местами, создавить клавиши переключения слоя, установить макросы.

# Скачать

[`bin/EnhancedKeyboard.exe`](https://github.com/klavarog/enhanced-keyboard/raw/master/bin/EnhancedKeyboard.exe).

# Возможности

* При нажатии на любую клавишу можно сделать следующее действие:
	* **Нажатие другой клавиши** (ремаппинг).
		* Можно поставить модификатор Ctrl, Alt, Shift.
	* **Макрос** (`Text`), более подробно об этом написано в `HelpRus.txt`, либо в `src/sndkey32.pas`.
		* TODO Вставить этот текст сюда
	* **Включение слоя следующим образом:**
		* Слой включается только когда клавиша нажата, по аналогии с Shift (`Key up`).
		* Слой включается после отпускания клавиши, и выключится, только если её нажать ещё раз, по аналогии с Caps Lock (`Toggle`).
		* Слой применяется только к следующей нажатой клавише (`Next key`).
		* Слой применяется после отпускания клавиши ещё некоторое время (`Key up + Delay`).
		* Так же при включении слоя можно выставить чтобы зажался модификатор Ctrl, Alt, Shift.
* Можно создавать разные конфигурации для разных языков.
* Сворачивание в трей.
* Все настройки хранятся в конфигурационном файле, реестр не используется, права администратора не требуются.
	* Соответственно для комфортной работы за любым компьютером под windows нужно просто иметь эту программу с собой на флешке.

# Пример использования

## Стрелки в домашней позиции

TODO, выложить конфигурацию, с моей философией и обычную, нарисованную в KLE

## По мелочам

* **Переключение раскладки одной клавишей.**
	* Если у вас раскладка переключается на `Shift+Alt`, то макрос `%+`. Если переключается на `Ctrl+Shift`, то `^+`.
* **Отдельные клавиши для Ctrl+C, Ctrl+V, Ctrl+A, Ctrl+Z.**
* **Отдельный слой с типографическими символами.**
	* TODO
* **Запятая с автоматическим пробелом**.

# Источник

К сожалению, кто автор этой программы, - неизвестно. Она не гуглится. Лицензия, под которой она распространяется - неизвестна.

Пошло всё отсюда: [Копия статьи на хабре](http://www.itshop.ru/Rasshiryaem-funktsionalnost-klaviatury/l9i31089) или она же в [архиве](https://web.archive.org/web/20170904124608/http://www.itshop.ru/Rasshiryaem-funktsionalnost-klaviatury/l9i31089); [тема на форуме](http://sharaga.org/index.php?showtopic=3810), она же в [архиве](https://web.archive.org/save/http://sharaga.org/index.php?showtopic=3810).