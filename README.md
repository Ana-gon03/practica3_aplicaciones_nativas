### Practica3 Alicaciones Nativas

Este proyecto es una aplicación **nativa para Android** desarrollada en **Kotlin**.  
La idea principal es crear un **gestor de archivos completo y moderno**, que permita explorar, visualizar y administrar carpetas y archivos del almacenamiento interno y externo del dispositivo.  

## ✨ Funcionalidades que tendrá

- Explorar carpetas y archivos de la memoria del teléfono  
- Mostrar la estructura de carpetas de forma jerárquica  
- Ver información como nombre, tamaño, tipo y fecha de modificación  
- Abrir archivos de texto (.txt, .json, .xml, .log, .md)  
- Visualizar imágenes con opciones de zoom, rotación y desplazamiento  
- Usar **intents** para abrir archivos con otras apps  
- Crear, renombrar, mover, copiar o eliminar archivos  
- Buscar archivos por nombre, tipo o fecha  
- Tener un historial de archivos recientes y un sistema de favoritos

## 🎨 Interfaz y Temas

La aplicación tendrá dos temas principales inspirados en el **IPN** y **ESCOM**:

| Tema | Color principal |
|:------|:----------------|
| 💜 Guinda (IPN) | `#6B2E5F` |
| 💙 Azul (ESCOM) | `#003D6D` |

Además, se adaptará automáticamente al modo claro u oscuro del sistema.  


---

## 📋 Estado del Proyecto

| Archivo | Estado | Descripción |
|:--------|:--------|:-------------|
| 🏠 `MainActivity.kt` | ✅ Listo | Pantalla principal con la lista de archivos |
| 📄 `FileItem.kt` | ✅ Listo | Modelo de datos para representar un archivo o carpeta |
| 🧱 Layouts base (`activity_main.xml`, `item_file.xml`) | ✅ Listos | Estructura inicial de la interfaz |
| 🧩 `FileAdapter.kt` | 🔧 En proceso | Adaptador para el RecyclerView |
| 🖼 `ImageViewerActivity.kt` | 🚧 Pendiente | Para visualizar imágenes |
| 📘 `FileViewerActivity.kt` | 🚧 Pendiente | Para visualizar archivos de texto |
| ⚙️ `PermissionUtils.kt` / `FileUtils.kt` | 🚧 Pendiente | Manejo de permisos y utilidades |

---

## 💾 Funcionalidades de almacenamiento

- Guardar favoritos de usuario (archivos o carpetas más usados)  
- Mantener un historial de archivos recientes  
- Generar caché de miniaturas para optimizar el rendimiento  

El almacenamiento se hará usando **Room**, **SharedPreferences** o **DataStore**, según la función.

---

## 🔐 Permisos y seguridad

Estoy implementando correctamente los permisos de lectura/escritura según la versión de Android,  
usando **Scoped Storage** para Android 10 o superior y manejando excepciones en rutas restringidas o archivos corruptos.

---

## 🧠 Tecnologías utilizadas

- **Lenguaje:** Kotlin  
- **IDE:** Android Studio  
- **Arquitectura:** MVVM (para mantener el código ordenado)  
- **UI:** Material Design Components  
- **Compatibilidad:** Android 10 (API 29) o superior  

---

## 🚀 Próximos pasos

- Terminar el adaptador de archivos  
- Agregar el visor de imágenes y archivos de texto  
- Implementar los temas dinámicos  
- Añadir el sistema de favoritos y recientes  
- Probar el manejo de permisos y almacenamiento externo  
 

---

📱 *Proyecto en desarrollo — versión inicial 0.1*  

