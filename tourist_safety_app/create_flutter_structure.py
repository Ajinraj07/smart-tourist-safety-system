import os

base_dir = r"c:\Users\AJINRAJ\Downloads\Whisk Downloads\tourist_safety_v1\tourist_safety_app\lib"

directories = [
    "core/network",
    "core/error",
    "core/theme",
    "core/router",
    "core/constants",
    "features/auth/data/datasources",
    "features/auth/data/models",
    "features/auth/data/repositories",
    "features/auth/domain/entities",
    "features/auth/domain/repositories",
    "features/auth/presentation/providers",
    "features/auth/presentation/screens",
    "features/auth/presentation/widgets",
    "features/dashboard/presentation/screens",
    "features/dashboard/presentation/providers",
    "features/dashboard/presentation/widgets",
    "features/places/data/datasources",
    "features/places/data/models",
    "features/places/data/repositories",
    "features/places/domain/entities",
    "features/places/domain/repositories",
    "features/places/presentation/providers",
    "features/places/presentation/screens",
    "features/places/presentation/widgets",
    "features/danger_zones/data/datasources",
    "features/danger_zones/data/models",
    "features/danger_zones/data/repositories",
    "features/danger_zones/domain/entities",
    "features/danger_zones/domain/repositories",
    "features/danger_zones/presentation/providers",
    "features/danger_zones/presentation/screens",
    "features/danger_zones/presentation/widgets",
    "features/alerts/data/datasources",
    "features/alerts/data/models",
    "features/alerts/data/repositories",
    "features/alerts/domain/entities",
    "features/alerts/domain/repositories",
    "features/alerts/presentation/providers",
    "features/alerts/presentation/screens",
    "features/alerts/presentation/widgets",
]

for d in directories:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

# Create some basic files to show structure
files = {
    "core/constants/api_constants.dart": "class ApiConstants {\n  static const String baseUrl = 'http://10.0.2.2:8000/api/';\n}\n",
    "core/theme/app_theme.dart": "import 'package:flutter/material.dart';\n\nclass AppTheme {\n  static ThemeData get lightTheme => ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue);\n}\n",
    "core/network/dio_client.dart": "import 'package:dio/dio.dart';\n\nclass DioClient {\n  final Dio dio = Dio();\n}\n",
    "core/router/app_router.dart": "import 'package:go_router/go_router.dart';\n\nfinal appRouter = GoRouter(routes: []);\n",
    "features/auth/presentation/screens/login_screen.dart": "import 'package:flutter/material.dart';\n\nclass LoginScreen extends StatelessWidget {\n  const LoginScreen({super.key});\n  @override\n  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login')));\n}\n",
    "features/dashboard/presentation/screens/tourist_dashboard_screen.dart": "import 'package:flutter/material.dart';\n\nclass TouristDashboardScreen extends StatelessWidget {\n  const TouristDashboardScreen({super.key});\n  @override\n  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dashboard')));\n}\n",
}

for f, content in files.items():
    path = os.path.join(base_dir, f)
    with open(path, "w") as file:
        file.write(content)

print("Flutter Clean Architecture Folder Structure Created Successfully!")
