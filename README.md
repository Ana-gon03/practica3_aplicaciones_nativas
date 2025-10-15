# 📁 Gestor de Archivos - Aplicación Móvil Nativa

## 📋 Descripción

**Gestor de Archivos** es una aplicación móvil nativa para Android desarrollada con Flutter que permite explorar, gestionar y visualizar archivos del dispositivo de manera eficiente y elegante. La aplicación ofrece acceso completo al almacenamiento interno y externo, con características avanzadas de búsqueda, filtrado y gestión de archivos.

### 🎯 Características Principales

#### 🗂️ Exploración de Archivos
- ✅ Acceso a almacenamiento interno y externo
- ✅ Navegación jerárquica con breadcrumbs
- ✅ Vista de lista y cuadrícula
- ✅ Información detallada de archivos (tamaño, fecha, tipo)
- ✅ Iconos diferenciados por tipo de archivo

#### 🔍 Búsqueda Avanzada
- ✅ Búsqueda recursiva en carpetas y subcarpetas
- ✅ Búsqueda rápida en carpeta actual
- ✅ Filtros por tipo de archivo:
  - Imágenes (JPG, PNG, GIF, WebP)
  - Documentos de texto (TXT, MD, JSON, XML)
  - Videos (MP4, AVI, MKV)
  - Audio (MP3, WAV, FLAC)
- ✅ Filtros por fecha:
  - Modificados hoy
  - Modificados esta semana (últimos 7 días)
- ✅ Contador de resultados en tiempo real

#### 📄 Visualización de Contenido
- ✅ **Visor de texto**: Archivos TXT, MD, LOG, JSON, XML
  - Control de tamaño de fuente
  - Texto seleccionable
  - Fuente monoespaciada para código
- ✅ **Visor de imágenes**: JPG, PNG, GIF, BMP, WebP
  - Zoom y desplazamiento
  - Rotación de imágenes
  - Fondo negro para mejor visualización
- ✅ **Apertura con aplicaciones externas**: Otros tipos de archivo

#### 🛠️ Gestión de Archivos
- ✅ Crear carpetas nuevas
- ✅ Renombrar archivos y carpetas
- ✅ Copiar archivos/carpetas
- ✅ Mover archivos/carpetas
- ✅ Eliminar con confirmación
- ✅ Información detallada del archivo

#### ⭐ Sistema de Favoritos
- ✅ Marcar archivos y carpetas como favoritos
- ✅ Acceso rápido desde pestaña dedicada
- ✅ Almacenamiento persistente
- ✅ Detección de archivos eliminados

#### 🕐 Historial de Archivos Recientes
- ✅ Registro automático de archivos abiertos
- ✅ Límite de 20 archivos recientes
- ✅ Deslizar para eliminar del historial
- ✅ Información de tamaño y fecha

#### 🎨 Temas Personalizables
- ✅ **Tema IPN Guinda** (#6B2E5F)
- ✅ **Tema ESCOM Azul** (#003D6D)
- ✅ Modo claro y oscuro para cada tema
- ✅ Adaptación automática al tema del sistema
- ✅ Persistencia de preferencias

#### 🔒 Permisos y Seguridad
- ✅ Gestión inteligente de permisos según versión Android
- ✅ Soporte para Scoped Storage (Android 10+)
- ✅ Permisos granulares (Android 13+)
- ✅ Manejo de excepciones robusto
- ✅ Respeto a restricciones de seguridad

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- **Flutter SDK**: >= 3.0.0
- **Dart SDK**: >= 3.0.0
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Dispositivo Android** o **Emulador** (API 21+)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/gestor-archivos.git
   cd gestor-archivos
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar dispositivos conectados**
   ```bash
   flutter devices
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

5. **Compilar APK para producción**
   ```bash
   flutter build apk --release
   ```

---

## 📦 Dependencias

### Principales
```yaml
provider: ^6.1.1              # Gestión de estado
path_provider: ^2.1.1         # Acceso a rutas del sistema
path: ^1.8.3                  # Manipulación de rutas
shared_preferences: ^2.2.2    # Almacenamiento local
permission_handler: ^11.1.0   # Gestión de permisos
photo_view: ^0.14.0          # Visor de imágenes con zoom
open_filex: ^4.3.4           # Apertura de archivos externos
intl: ^0.18.1                # Internacionalización
mime: ^1.0.4                 # Detección de tipos MIME
```

---

## 🏗️ Arquitectura del Proyecto

### Estructura de Carpetas

```
lib/
├── main.dart                    # Punto de entrada
├── app.dart                     # Configuración principal
├── config/
│   ├── themes/
│   │   ├── app_theme.dart      # Definición de temas
│   │   └── theme_provider.dart # Provider de temas
│   └── constants/
│       └── app_constants.dart  # Constantes globales
├── models/
│   ├── file_item.dart          # Modelo de archivo/carpeta
│   └── favorite_item.dart      # Modelo de favorito
├── services/
│   ├── file_service.dart       # Operaciones de archivos
│   ├── storage_service.dart    # Gestión de almacenamiento
│   └── permission_service.dart # Gestión de permisos
├── providers/
│   ├── file_provider.dart      # Estado de explorador
│   ├── favorites_provider.dart # Estado de favoritos
│   └── recent_files_provider.dart # Estado de recientes
├── screens/
│   ├── home_screen.dart        # Pantalla principal
│   ├── file_explorer_screen.dart # Explorador de archivos
│   ├── text_viewer_screen.dart   # Visor de texto
│   ├── image_viewer_screen.dart  # Visor de imágenes
│   ├── favorites_screen.dart     # Pantalla de favoritos
│   └── recent_files_screen.dart  # Pantalla de recientes
└── widgets/
    ├── file_item_widget.dart   # Widget de archivo
    ├── breadcrumb_widget.dart  # Navegación breadcrumb
    ├── empty_state_widget.dart # Estado vacío
    └── permission_dialog.dart  # Diálogo de permisos
```
---

## 🎨 Temas y Diseño

### Colores IPN Guinda

| Elemento | Claro | Oscuro |
|----------|-------|--------|
| Primario | #6B2E5F | #8B4E7F |
| Secundario | #8B4E7F | #6B2E5F |
| Fondo | #FFFFFF | #121212 |
| Superficie | #FFFFFF | #1E1E1E |

<p align="center">
  <img src="https://github.com/user-attachments/assets/7600f72e-7c31-4bbf-bb71-2d8deb97b482" alt="imagen" width="400">
</p>



### Colores ESCOM Azul

| Elemento | Claro | Oscuro |
|----------|-------|--------|
| Primario | #003D6D | #005D9D |
| Secundario | #005D9D | #003D6D |
| Fondo | #FFFFFF | #121212 |
| Superficie | #FFFFFF | #1E1E1E |

<p align="center">
  <img src="https://github.com/user-attachments/assets/2d375eda-b2b5-412f-94fc-3da3b8fafc14" alt="imagen2" width="400">
</p>

---

## 📱 Capturas de Pantalla

### Pantalla Principal
- Explorador de archivos con vista de lista/cuadrícula
- Barra de navegación con breadcrumbs
- Acceso rápido a favoritos y recientes
<p align="center">
  <img src="https://github.com/user-attachments/assets/d03df017-bcfb-4fb4-b9ed-923cff43c760" alt="imagen3" width="400">
</p>

### Búsqueda Avanzada
- Campo de búsqueda con sugerencias
- Filtros por tipo y fecha

<p align="center">
  <img src="https://github.com/user-attachments/assets/0293042b-5dfc-447e-b540-d2e60b301594" width="200">
  <img src="https://github.com/user-attachments/assets/4dd083a7-d7d8-4721-9013-b2b3ba19c4eb" width="200">
</p>

### Favoritos y Recientes
<p align="center">
  <img src="https://github.com/user-attachments/assets/40536584-f776-4d69-b63b-50cf8df8eb82" width="300">
  <img src="https://github.com/user-attachments/assets/8c704318-797e-43d6-ba08-d6d81a12d583" width="300">
</p>



### Gestión de Archivos
- Opciones contextuales (copiar, mover, eliminar)
- Diálogos de confirmación
- Mensajes de retroalimentación
<p align="center">
  <img src="https://github.com/user-attachments/assets/6331f975-f10f-4d1e-a4e2-e9820a279637" alt="imagen" width="400">
</p>


### Video

---

## 🔐 Permisos Requeridos

### Android Manifest
```xml
<!-- Android 10 y anteriores -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Android 11+ -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Android 13+ -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

### Gestión Automática
La aplicación solicita automáticamente los permisos necesarios según la versión de Android del dispositivo.

---

## 📊 Características Técnicas

### Compatibilidad
- ✅ Android 5.0 (API 21) o superior
- ✅ Soporte para diferentes tamaños de pantalla
- ✅ Orientación vertical y horizontal
- ✅ Adaptación a modo oscuro del sistema

### Almacenamiento Local
- ✅ SharedPreferences para favoritos y recientes
- ✅ Persistencia de preferencias de tema
- ✅ Sin uso de bases de datos externas

---

## 🐛 Solución de Problemas

### La búsqueda no encuentra archivos
1. Verifica que tengas permisos de almacenamiento
2. Intenta usar "Solo aquí" para búsqueda en carpeta actual
3. Revisa los logs de Flutter para más detalles

### No se muestran carpetas del almacenamiento
1. Ve a Configuración → Aplicaciones → Gestor Archivos
2. Permisos → Archivos y multimedia
3. Selecciona "Permitir acceso a todos los archivos"

### La aplicación se cierra al abrir un archivo
1. Asegúrate de tener una aplicación compatible instalada
2. Verifica que el archivo no esté corrupto
3. Revisa los permisos de la aplicación

---



<div align="center">



</div>
