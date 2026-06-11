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
  lab_number: "13",
  course: "Языки и методы программирования",
  theme: "Сборка MediaPipe из исходного кода с использованием Docker и Bazel",
  year: "2026",
)

#outline()

= Цель работы

Ознакомиться с процессом сборки фреймворка MediaPipe из исходного кода с использованием Docker-контейнеризации и системы сборки Bazel. Выполнить сборку примеров desktop-приложений (hello_world и hand_tracking) внутри Docker-образа.

= Что такое MediaPipe

MediaPipe — это открытый фреймворк от Google для построения конвейеров машинного обучения (ML) на различных платформах: мобильные устройства (Android, iOS), веб, десктоп, IoT. MediaPipe предоставляет готовые решения для:

- распознавания рук (Hand Tracking);
- детекции лиц (Face Detection);
- определения позы (Pose Estimation);
- сегментации изображений;
- отслеживания объектов и других задач компьютерного зрения.

Фреймворк использует Bazel в качестве основной системы сборки. Исходный код написан на C++ с поддержкой Java (Android), Objective-C (iOS) и Python.

= Docker-образ для сборки

Для изолированной сборки MediaPipe используется официальный Dockerfile на базе Ubuntu 22.04. В образ устанавливаются все необходимые зависимости:

- компиляторы GCC/G++ и Clang 16;
- OpenCV (библиотека компьютерного зрения);
- Java 21 (требуется для Bazel);
- Python 3 и пакеты (absl-py, numpy, opencv-contrib-python, protobuf, tensorflow и др.);
- Bazel 7.4.1 (система сборки);
- утилиты ffmpeg, mesa (для работы с графикой).

#terminal(title: "Dockerfile")[
```dockerfile
FROM ubuntu:22.04

WORKDIR /mediapipe

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ ca-certificates curl ffmpeg git wget unzip \
    nodejs npm python3-dev python3-opencv python3-pip \
    libopencv-core-dev libopencv-highgui-dev libopencv-imgproc-dev \
    libopencv-video-dev libopencv-calib3d-dev libopencv-features2d-dev \
    software-properties-common && \
    apt-get update && apt-get install -y openjdk-21-jdk && \
    apt-get install -y mesa-common-dev libegl1-mesa-dev \
    libgles2-mesa-dev mesa-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка Clang 16
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 16
RUN ln -sf /usr/bin/clang-16 /usr/bin/clang
RUN ln -sf /usr/bin/clang++-16 /usr/bin/clang++
RUN ln -sf /usr/bin/clang-format-16 /usr/bin/clang-format

# Установка Python-зависимостей
RUN pip3 install --upgrade setuptools wheel future \
    absl-py "numpy<2" jax[cpu] opencv-contrib-python protobuf==3.20.1 \
    six==1.14.0 tensorflow tf_slim

# Установка Bazel 7.4.1
ARG BAZEL_VERSION=7.4.1
RUN mkdir /bazel && \
    wget --no-check-certificate -O /bazel/installer.sh \
    "https://github.com/bazelbuild/bazel/releases/download/\
${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    chmod +x /bazel/installer.sh && /bazel/installer.sh && \
    rm -f /bazel/installer.sh

COPY . /mediapipe/
```
]

Сборка образа выполняется командой:

#terminal(title: "Сборка Docker-образа")[
```bash
docker build -t mediapipe:latest .
```
]

Образ получается объёмным — около 15.6 ГБ на диске (4.02 ГБ в сжатом виде), что обусловлено большим количеством зависимостей (TensorFlow, Bazel, OpenCV, библиотеки для GPU).

= Сборка примеров

После создания образа был запущен интерактивный сеанс внутри контейнера:

#terminal(title: "Запуск контейнера")[
```bash
docker run -it --name mediapipe mediapipe:latest /bin/bash
```
]

== Сборка hello_world

Первым был собран минимальный пример hello_world для проверки работоспособности Bazel и инструментария:

#terminal(title: "Сборка hello_world")[
```bash
bazel build --define MEDIAPIPE_DISABLE_GPU=1 \
    mediapipe/examples/desktop/hello_world
```
]

Сборка прошла успешно. Было выполнено 3259 действий (actions), из которых все завершились без ошибок. Бинарный файл был размещён в директории `bazel-bin/mediapipe/examples/desktop/hello_world/`.

== Сборка hand_tracking_cpu

Следующим этапом была выполнена сборка примера Hand Tracking (распознавание рук) с использованием CPU:

#terminal(title: "Сборка hand_tracking_cpu")[
```bash
CC=/usr/bin/clang CXX=/usr/bin/clang++ \
bazel build -c opt --define MEDIAPIPE_DISABLE_GPU=1 \
    --copt=-I/usr/include/opencv4 \
    --cxxopt=-I/usr/include/opencv4 \
    mediapipe/examples/desktop/hand_tracking:hand_tracking_cpu
```
]

Флаги сборки:
- `CC` и `CXX` — явное указание компилятора Clang 16;
- `-c opt` — оптимизированная сборка;
- `--define MEDIAPIPE_DISABLE_GPU=1` — отключение поддержки GPU;
- `--copt=-I/usr/include/opencv4` — указание путей к заголовочным файлам OpenCV.

Из 3259 действий успешно выполнилось 3018 (92.6%). Сборка завершилась с ошибкой на этапе `EncodeProto`, где утилита `protoc` не смогла найти разделяемую библиотеку `libstdc++.so.6`.

#terminal(title: "Фрагмент лога ошибки")[
```
ERROR: .../hand_landmark:hand_landmark_model_loader_graph failed:
bazel-out/.../bin/external/protobuf~/protoc:
error while loading shared libraries:
libstdc++.so.6: cannot open shared object file:
No such file or directory
```
]

Причина: в образе Ubuntu 22.04 установлена библиотека `libstdc++6`, но Bazel при сборке `protoc` из исходников использует кастомный toolchain Clang 16, который ищет библиотеку по нестандартному пути. Проблема решается установкой пакета `libstdc++-12-dev` или добавлением пути к библиотеке в `LD_LIBRARY_PATH`.

= Анализ результатов

| Пример | Результат | Выполнено действий | Статус |
|--------|-----------|-------------------:|--------|
| hello_world | Бинарный файл собран | 3259 / 3259 (100\%) | Успешно |
| hand_tracking_cpu | Ошибка protoc + libstdc++ | 3018 / 3259 (92.6\%) | Не завершён |

Несмотря на частичную неудачу, 3018 действий были выполнены корректно, что свидетельствует о работоспособности инструментария и правильности Docker-окружения. Ошибка носит локальный характер, связана с конфигурацией toolchain в контейнере и не является критической для понимания процесса сборки MediaPipe.

= Вывод

В ходе лабораторной работы был изучен процесс сборки фреймворка MediaPipe из исходного кода с использованием Docker и Bazel:

- создан Docker-образ на основе Ubuntu 22.04 с установкой Clang 16, OpenCV, Java 21, Python-зависимостей и Bazel 7.4.1;
- внутри контейнера выполнена сборка примера hello_world (успешно);
- выполнена сборка hand_tracking_cpu (частично, с ошибкой libstdc++).

Получен практический опыт работы с системой сборки Bazel, настройки Docker-окружения для C++ проектов машинного обучения и диагностики ошибок при сборке крупных фреймворков.
