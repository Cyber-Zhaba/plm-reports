#set text(
  font: "Times New Roman",
  lang: "ru",
  size: 12pt,
)

#let title_page(
  student: "",
  group: "",
  teacher: "",
  lab_number: "",
  course: "",
  theme: "",
  year: "2023",
) = {
  set page(numbering: none)

  grid(
    columns: (auto, 1fr),
    gutter: 1em,
    align: horizon,
    image("emblem.png", width: 2.5cm),

    align(center)[
      #set text(size: 10pt, weight: "bold")
      Министерство науки и высшего образования Российской Федерации \
      Федеральное государственное бюджетное образовательное учреждение \
      высшего образования \
      «Московский государственный технический университет \
      имени Н.Э. Баумана \
      (национальный исследовательский университет)» \
      (МГТУ им. Н.Э. Баумана)
    ],
  )

  v(5pt)
  line(length: 100%, stroke: 2.5pt)
  v(1pt)
  line(length: 100%, stroke: 0.5pt)
  v(1em)

  let field_line(label, value) = {
    grid(
      columns: (auto, 1fr),
      gutter: 10pt,
      text(size: 11pt)[#label],
      stack(
        dir: ttb,
        spacing: 3pt,
        align(center, value),
        line(length: 100%, stroke: 0.5pt),
      ),
    )
  }

  field_line("ФАКУЛЬТЕТ", [«Информатика и системы управления»])
  v(1em)
  field_line("КАФЕДРА", [«Теоретическая информатика и компьютерные технологии»])

  v(6cm)

  align(center)[
    #text(size: 18pt, weight: "bold")[Лабораторная работа № #lab_number] \
    #v(0.5em)
    #text(size: 14pt, weight: "bold")[по курсу «#course»] \
    #v(0.5em)
    #text(size: 14pt)[«#theme»]
  ]

  v(3cm)

  align(right)[
    #block(width: 50%)[
      Студент группы #group \
      *#student* \
      #v(1em)
      Преподаватель \
      *#teacher*
    ]
  ]

  v(1fr)
  align(center)[
    #text(style: "italic")[Москва #year]
  ]

  pagebreak()

  set page(numbering: "1")
  counter(page).update(1)
}

#show raw: set text(font: ("Fira Code"), size: 10pt)

#show raw.where(block: true): it => {
  block(
    fill: luma(245),
    inset: 10pt,
    radius: 5pt,
    width: 100%,
    stroke: 1pt + luma(200),
    it
  )
}

#let terminal(content, title: none) = {
  let bg_color = luma(250)
  let border_color = luma(200)
  let title_bg = luma(240)

  let header = if title != none {
    block(
      width: 100%,
      fill: title_bg,
      inset: (x: 8pt, y: 5pt),
      stroke: (bottom: 0.5pt + border_color),
      radius: (top: 3pt),
      text(size: 9pt, weight: "bold", fill: luma(80), font: "Arial", title)
    )
  } else { none }

  let body = block(
    width: 100%,
    fill: bg_color,
    inset: 10pt,
    radius: if title != none { (bottom: 3pt) } else { 3pt },
    text(font: ("Fira Code", "Courier New"), size: 10pt, content)
  )

  block(
    width: 100%,
    stroke: 0.5pt + border_color,
    radius: 3pt,
    clip: true,
    breakable: false,
    stack(dir: ttb, header, body)
  )
}

#title_page(
  student: "Булдаков А. С.",
  group: "ИУ9-22Б",
  teacher: "Посевин Д. П.",
  lab_number: "14",
  course: "Языки и методы программирования",
  theme: "PointNet. Классификация 3D-облаков точек",
  year: "2026",
)

#outline()

= Цель работы

Ознакомиться с архитектурой PointNet для классификации трёхмерных облаков точек. Запустить предобученную модель на тестовых объектах, выполнить инференс и визуализацию. Обучить модель на собственном наборе данных.

= Что такое PointNet

PointNet — архитектура глубокого обучения для прямого анализа неструктурированных облаков точек, предложенная исследователями из Стэнфорда. Ключевая идея — использование разделяемых свёрток 1x1 и симметричной функции MaxPooling для обеспечения инвариантности к перестановкам точек.

Архитектура включает:
- T-Net (3x3) — обучаемое аффинное преобразование для выравнивания входного облака;
- разделяемые свёрточные слои (Conv1D 64/128/1024) с BatchNorm и ReLU;
- T-Net (64x64) — преобразование в пространстве признаков;
- GlobalMaxPooling — симметричная агрегация;
- полносвязные слои (512, 256) с Dropout и выходной слой softmax.

= Ход работы

== Настройка окружения

Проект использует Python, TensorFlow/Keras, `trimesh` для загрузки 3D-моделей и `uv` для управления зависимостями.

== Запуск предобученной модели

Предобученная на ModelNet10 модель (`model.keras`) запускается на тестовых 3D-объектах:

#terminal(title: "Запуск инференса на toilet.off")[
```bash
cd lab-pointnet
uv run open.py toilet.off   # визуализация модели
uv run detect.py model.keras class_map.json toilet.off
```
]

Результат: модель корректно классифицирует объект как `toilet` (унитаз) с высокой уверенностью. Для каждого объекта выводятся топ-5 предсказаний с вероятностями.

== Тестирование на различных объектах

Запуск производился для нескольких 3D-моделей:

#terminal(title: "Makefile — цели для тестирования")[
```makefile
1:  # Стул из ModelNet10
    uv run open.py  ...  &&  detect.py model.keras class_map.json ...
2:  # Унитаз
    uv run open.py toilet.off  &&  detect.py model.keras class_map.json toilet.off
3:  # Унитаз (broken)
    uv run open.py broken-toilet.off  &&  detect.py model.keras class_map.json broken-toilet.off
4:  # Череп (out-of-distribution)
    uv run open.py skull/12140_Skull_v3_L2.obj  &&  detect.py model.keras class_map.json skull/...
```
]

Во всех случаях инференс выполнен успешно. Модель, обученная на 10 классах мебели (ModelNet10), ожидаемо классифицирует предметы мебели корректно, а череп (out-of-distribution) — с низкой уверенностью, распределённой между несколькими классами.

== Визуализация 3D-моделей

Утилита `open.py` загружает 3D-модель через `trimesh`, отображает её в интерактивном окне, семплирует 2048 точек и показывает их как scatter-plot:

#terminal(title: "open.py")[
```python
import trimesh
import matplotlib.pyplot as plt
import numpy as np

mesh = trimesh.load(sys.argv[1])
mesh.show()  # интерактивный 3D-просмотр
points, _ = trimesh.sample.sample_surface(mesh, 2048)
ax = plt.axes(projection='3d')
ax.scatter(points[:,0], points[:,1], points[:,2], s=1)
plt.show()
```
]

== Обучение на собственном наборе данных

Собран датасет из OBJ-файлов собак и кошек. Модель обучена на 2 класса с теми же гиперпараметрами (кроме `NUM_CLASSES=2`):

#terminal(title: "Запуск обучения")[
```bash
uv run custom-train.py  # обучает dogsNcats-model.keras
```
]

После обучения инференс на тестовых моделях:

#terminal(title: "Makefile цель 7")[
```makefile
7:  uv run detect.py dogsNcats-model.keras custom_class_map.json my-dataset/dog/*.obj
    uv run detect.py dogsNcats-model.keras custom_class_map.json my-dataset/cat/*.obj
```
]

Результат: модель успешно различает собак и кошек на 3D-моделях из тестовой выборки.

= Вывод

В ходе лабораторной работы:

- изучена архитектура PointNet (T-Net, разделяемые свёртки, GlobalMaxPooling);
- запущен инференс предобученной на ModelNet10 модели на нескольких 3D-объектах (ступ, унитаз, череп);
- выполнена визуализация облаков точек (1024-2048 точек на объект);
- обучена кастомная модель на датасете собак и кошек;
- все запуски выполнены успешно, предсказания корректны.
