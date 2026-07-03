# fixy-ios
# Fixy

Fixy es una app de iOS que conecta a personas que necesitan un servicio o reparación con profesionales disponibles cerca de ellas. Los usuarios publican solicitudes ("requests"), pueden buscar prestadores de servicio, hacer seguimiento del estado de sus pedidos y calificar el trabajo realizado.

## Stack tecnológico

- **Swift / SwiftUI** — interfaz declarativa
- **MVVM** — Views solo manejan UI; la lógica vive en `ViewModel`s (`ObservableObject`) organizados por feature
- **Supabase** — backend (autenticación con email/password y Google Sign-In, base de datos, sesión de usuario)
- **async/await** — llamadas de red y operaciones asíncronas

## Capturas de pantalla

## Video de demostración
aun no se envio 

## Integrantes

<!-- TODO: nombres completos de todo el equipo -->
-Ancco Condori, André Favio
-Gutierrez Nina, Luciana Gabriela
-Llano Flores, Carlos Alberto
-Nuñez Arenas, Gabriel Emilio
-Sapacayo Mamani, Yordan Romel
-Salazar Ccorahua Joshua Jhair


## Estructura del proyecto

```
fixy/
├── App/                    # Entry point (fixyApp.swift)
├── Core/
│   ├── DesignSystem/       # Tema visual y modifiers reutilizables
│   ├── Network/            # SupabaseManager, SessionManager
│   ├── Constants/
│   └── Utils/
└── Features/                # Un módulo MVVM por feature
    ├── Authentication/
    ├── Home/
    ├── CreateRequest/
    ├── Requests/
    ├── RequestDetail/
    ├── Search/
    ├── Notification/
    ├── Ranking/
    ├── Profile/
    └── MainNavigation/
```

## Configuración del proyecto

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/Fixy-tec/fixy-ios.git
   ```
2. Abrir `fixy/fixy.xcodeproj` en Xcode.
3. Las credenciales de Supabase (`SupabaseURL`, `SupabaseAnonKey`) se leen desde el `Info.plist` del proyecto. Pide el archivo de configuración al equipo o crea el tuyo propio con tu proyecto de Supabase.
4. Compilar y correr en un simulador de iOS (⌘R).

## Funcionalidades principales

- Registro e inicio de sesión (email/password y Google Sign-In)
- Publicación de solicitudes de servicio
- Búsqueda de solicitudes/profesionales
- Seguimiento del estado de las solicitudes propias
- Perfil de usuario editable
- Notificaciones y ranking de usuarios
