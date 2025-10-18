import 'dart:typed_data';
import 'package:app/core/permission_services.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/profile/data/models/kyc_data_model.dart';
import 'package:app/features/profile/data/repositories/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class KycFormPage extends StatefulWidget {
  const KycFormPage({super.key});

  @override
  State<KycFormPage> createState() => _KycFormPageState();
}

class _KycFormPageState extends State<KycFormPage> {
  bool _editing = false;

  final TextEditingController _bvnController = TextEditingController();
  final TextEditingController _ninController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  String? selectedIDMethod;

  KYCData? currentKyc;

  Uint8List? pickedFile;

  /// Helper to ask user whether to use Camera or Gallery
  Future<ImageSource> _chooseImageSource() async {
    return await showModalBottomSheet<ImageSource>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder:
              (ctx) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text("Camera"),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text("Gallery"),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: const Text("Cancel"),
                      onTap: () => Navigator.pop(ctx, null),
                    ),
                  ],
                ),
              ),
        ) ??
        ImageSource.gallery;
  }

  _pickImage() async {
    bool granted =
        await PermissionService.requestCameraPermission() &&
        await PermissionService.requestGalleryPermission();

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera Permission was denied.")),
      );
      return;
    }

    var picked = await _picker.pickImage(
      source: await _chooseImageSource(),
      imageQuality: 85, // compress a bit
    );

    if (picked == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image selected")));
      setState(() => _isLoading = false);
      return;
    }

    var bytes = await picked?.readAsBytes();
    setState(() {
      pickedFile = bytes;
    });
  }

  _loadKycStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await ProfileService().retriveKYCStatus(
        context.read<AuthProvider>().authToken ?? "",
      );
      setState(() {
        currentKyc = res;
        _bvnController.text = res?.bvn ?? "";
        _ninController.text = res?.nin ?? "";
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to load KYC information. please try again"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _submitKYCData() async {
    if ((_ninController.text.trim().isEmpty ||
            _bvnController.text.trim().isEmpty ||
            pickedFile == null) &&
        (currentKyc?.idImage?.isEmpty ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all the information required!"),
        ),
      );
      return;
    }

    if (currentKyc != null && (currentKyc?.isApproved ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your KYC is already approved, please contact support to make changes!",
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // let user pick image

      if (pickedFile == null) {
        return;
      }

      // Convert picked image to ByteData
      final ByteData imageData = ByteData.sublistView(pickedFile!);

      // Construct KYCData (example - adjust as per your model)
      final kycData = KYCData(
        bvn: _bvnController.text,
        nin: _ninController.text,
      );

      var res = await ProfileService().submitKYCData(
        context.read<AuthProvider>().authToken ?? "",
        kycData,
        imageData,
        isUpdate: currentKyc != null,
      );

      if (res != null) {
        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: EdgeInsets.all(20),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Your KYC Data has been received successfully. You will be notified after the we finish reviewing your information",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          );
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("KYC submission failed")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to submit KYC information. please try again"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _loadKycStatus();
    super.initState();
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _ninController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('KYC', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadKycStatus,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),

          TextButton(
            onPressed: () => setState(() => _editing = !_editing),
            child: Text(
              _editing ? "Cancel" : "Edit",
              style: TextStyle(
                color: _editing ? Colors.black : Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 172, 210, 255),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 72, 155, 255),
                    ),
                  ),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "NOTE: Make sure the ID provided is valid and matches your name",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              TextFormField(
                enabled: _editing && !_isLoading,
                controller: _bvnController,
                decoration: const InputDecoration(
                  counterStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 12),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),

                  labelText: 'BVN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: _editing && !_isLoading,
                controller: _ninController,
                decoration: const InputDecoration(
                  counterStyle: TextStyle(fontSize: 12),
                  hintStyle: TextStyle(fontSize: 12),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  labelText: 'NIN',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [Text("Upload NIN slip picture:")]),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _editing && !_isLoading ? _pickImage : null,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      pickedFile == null
                          ? (currentKyc?.idImage?.isNotEmpty ?? false)
                              ? Image.network(
                                currentKyc?.idImage ?? "",
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.upload_file),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 40,
                                    color: Colors.grey[700],
                                  ),
                                  Text("Pick image"),
                                ],
                              )
                          : Image.memory(pickedFile!),
                ),
              ),
              const SizedBox(height: 16),
              MaterialButton(
                onPressed:
                    _isLoading && (currentKyc?.isApproved ?? false)
                        ? null
                        : _submitKYCData,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 50,
                minWidth: 200,
                color: Colors.blueAccent,
                child:
                    _isLoading
                        ? CircularProgressIndicator()
                        : Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
