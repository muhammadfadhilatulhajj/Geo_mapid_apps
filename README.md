# 🗺️ Geo MAPID - Peta Explorer (Flutter GIS App)

Aplikasi mobile GIS modern yang dibangun menggunakan **Flutter**, menerapkan arsitektur **BLoC & Clean Architecture**, dengan visualisasi peta berbasis **MapLibre GL** dan basemap eksternal **OpenFreeMap Liberty**, serta mengonsumsi layer data spasial dari **GEO MAPID API**.

Dibuat sebagai submission **Mobile Developer Technical Case Study - MAPID**.

---

## ✨ Fitur Utama

- 🧭 **Basemap Eksternal OpenFreeMap Liberty**: Rendering peta vektor interaktif dengan performa tinggi via `maplibre_gl` menggunakan style `https://tiles.openfreemap.org/styles/liberty`.
- 📍 **Layer Data GEO MAPID**: Mengambil data spasial (GeoJSON) Pariwisata Jogja secara real-time dari GeoServer API GEO MAPID dan me-rendernya di atas basemap.
- 🔍 **Real-time Live Search**: Pencarian cerdas instan berdasarkan nama objek wisata, alamat, atau wilayah dengan navigasi kamera otomatis ke lokasi yang ditemukan.
- 📱 **Interactive Detail Popup Modal**: Menampilkan informasi lengkap objek saat marker di-tap (Alamat resmi, Kelurahan/Desa, Kecamatan, Kota/Kab, Provinsi, Koordinat GPS, dan Kontributor).
- 📍 **GPS Location Tracker**: Mengambil posisi GPS pengguna saat ini (`geolocator`), menandainya dengan marker beranimasi halo, serta navigasi cepat via tombol *My Location*.
- 🎛️ **Floating Action Controls**: Navigasi ramah pengguna yang mencakup tombol Kompas Arah Utara, Zoom In/Out, Refresh Layer, dan Info Tooltip.
- 🎨 **Modern & Seamless UI**: Dilengkapi animasi Splash Screen bernuansa dark tech, kustom icon aplikasi native (Android & iOS), serta tema konsisten.
- 🔒 **Keamanan Kredensial (.env)**: Seluruh API key dan endpoint penting disimpan di environment variables via `flutter_dotenv` dan terlindungi di `.gitignore`.

---

## 🏛️ Arsitektur Proyek (Clean Architecture)

Proyek ini menerapkan **Feature-first Clean Architecture** yang memisahkan tanggung jawab bisnis murni, pengelolaan data, dan antarmuka pengguna:

```text
lib/
├── app/
│   └── app.dart                              # MultiBlocProvider & MaterialApp configuration
├── core/
│   ├── constants/
│   │   └── app_constants.dart                # Environment variables & default coordinates
│   ├── errors/
│   │   ├── exceptions.dart                   # ServerException, LocationException
│   │   └── failures.dart                     # Either Failures abstraction
│   ├── network/
│   │   └── api_client.dart                   # Dio HTTP Client wrapper & timeout settings
│   ├── services/
│   │   ├── injection_container.dart          # Dependency Injection (GetIt Service Locator)
│   │   └── location_service.dart             # Geolocator Service & Permission handler
│   └── theme/
│       └── app_theme.dart                    # Modern theme palette & component styles
│
└── features/
    └── map_viewer/
        ├── data/
        │   ├── datasources/
        │   │   └── geo_mapid_remote_data_source.dart # Fetch endpoint GEO MAPID
        │   ├── models/
        │   │   └── geo_feature_model.dart            # GeoJSON parsing model
        │   └── repositories/
        │       └── map_repository_impl.dart          # Either<Failure, T> repository mapping
        ├── domain/
        │   ├── entities/
        │   │   └── geo_feature_entity.dart           # Pure business entities
        │   ├── repositories/
        │   │   └── map_repository.dart               # Domain repository contract
        │   └── usecases/
        │       ├── get_geo_layer_usecase.dart        # UseCase fetch data layer
        │       └── get_current_location_usecase.dart # UseCase fetch GPS coordinate
        └── presentation/
            ├── bloc/
            │   ├── map_bloc.dart                     # BLoC State Management
            │   ├── map_event.dart                    # MapEvent declarations
            │   └── map_state.dart                    # MapState definitions
            ├── pages/
            │   ├── splash_screen.dart                # Animated branded splash screen
            │   └── map_page.dart                     # MapLibre map viewer & search interface
            └── widgets/
                ├── feature_detail_sheet.dart         # Modern object detail popup card
                └── map_floating_actions.dart         # Floating map controls stack
```

---

## 🛠️ Tech Stack & Dependencies

| Kategori | Library / Teknologi | Kegunaan |
|---|---|---|
| **State Management** | `flutter_bloc: ^9.1.1` | State management terprediksi & terisolasi |
| **Map Rendering** | `maplibre_gl: ^0.27.1` | Rendering basemap vector tile MapLibre |
| **Basemap Provider** | OpenFreeMap Liberty | Basemap tiles bergaya modern & responsif |
| **Networking** | `dio: ^5.11.1` | HTTP client untuk komunikasi API GEO MAPID |
| **Service Locator** | `get_it: ^9.3.0` | Dependency Injection antar layer |
| **Geolokasi** | `geolocator: ^14.0.3` | Mengakses GPS perangkat pengguna |
| **Security** | `flutter_dotenv: ^6.0.1` | Manajemen environment variables (.env) |
| **Functional Error** | `dartz: ^0.10.1` & `equatable: ^3.0.0` | Tipe data `Either<Failure, T>` & value equality |

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK (versi >= 3.12.0)
- Android Studio / Xcode untuk emulator atau perangkat fisik

### 2. Kloning Repository
```bash
git clone https://github.com/USERNAME/geo-mapid-app.git
cd geo-mapid-app
```

### 3. Konfigurasi Environment Variable (`.env`)
Salin template `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Pastikan file `.env` berisi konfigurasi berikut:
```env
GEO_MAPID_BASE_URL=https://geoserver.mapid.io/layers_new/get_layer
GEO_MAPID_API_KEY=8a41b8d031864ba9ae82ccff447460f3
GEO_MAPID_LAYER_ID=6aaa479abf51a2f0185a601b
GEO_MAPID_PROJECT_ID=6aa3b36388f2c84b0c10cb58
OPENFREEMAP_STYLE_URL=https://tiles.openfreemap.org/styles/liberty
```
*(Catatan: File `.env` sudah masuk ke dalam `.gitignore` sesuai standar keamanan kredensial).*

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Jalankan Aplikasi
```bash
flutter run
```

### 6. Build File APK (Release)
```bash
flutter build apk
```
File APK yang dihasilkan akan berada di:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Validasi & Testing

Aplikasi telah lulus pengujian kode dan analisis statis:
- **Flutter Analyzer**:
  ```bash
  flutter analyze
  # Output: No issues found! (0 warning, 0 error)
  ```
- **Unit Testing**:
  ```bash
  flutter test
  # Output: All tests passed!
  ```

---

## 📜 Git Commit History
Repository ini dirawat dengan alur commit yang terstruktur, bertahap, dan deskriptif (mengikuti konvensi *Conventional Commits*):
- `feat: initialize flutter project and configure maplibre dependencies`
- `feat(core): implement core network, errors, constants, theme, and injection container`
- `feat(map): implement domain layer (entities, repository contract, and usecases)`
- `feat(map): implement data layer (remote datasource, models, and repository impl)`
- `feat(map): implement BLoC state management for map viewer`
- `feat(presentation): implement MapLibre GL viewer with OpenFreeMap, tap popup, and GPS location`
- `feat(ui): add animated splash screen and revamp modern interactive popup card`
- `feat(branding): replace app launcher icons with custom modern Geo MAPID icon matching splash screen`

---

**Developed with ❤️ for MAPID Technical Case Study.**
