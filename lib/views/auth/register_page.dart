// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/auth_viewmodel.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   void _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     final authVM = Provider.of<AuthViewModel>(context, listen: false);
//     final success = await authVM.signUpWithEmail(
//       _emailController.text,
//       _passwordController.text,
//     );

//     if (success && mounted) {
//       Navigator.pop(context);
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(authVM.errorMessage ?? 'Registration Failed')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authVM = context.watch<AuthViewModel>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text('Create Account',
//             style: TextStyle(color: Color(0xFF0F172A))),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email Address',
//                   filled: true,
//                   fillColor: const Color(0xFFF8FAFC),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 validator: (v) => v!.trim().isEmpty ? 'Enter email' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   filled: true,
//                   fillColor: const Color(0xFFF8FAFC),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 validator: (v) =>
//                     v!.length < 6 ? 'Password must be 6+ characters' : null,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: authVM.isLoading ? null : _register,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4F46E5),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                 ),
//                 child: authVM.isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('Create Account',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }