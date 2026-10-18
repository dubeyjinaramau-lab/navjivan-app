
import 'package:flutter/material.dart';

class ChildrenDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ChildrenDetailsScreen({
    super.key,
    this.initialData,
  });

  @override
  State<ChildrenDetailsScreen> createState() =>
      _ChildrenDetailsScreenState();
}

class _ChildrenDetailsScreenState
    extends State<ChildrenDetailsScreen> {
  String? count;
  String? ageGroup;
  String? livingWith;
  String? financialResponsibility;
  String? careResponsibility;
  String? partnerRole;

  final detailsController = TextEditingController();

  final List<String> responsibilityOptions = [
    'शिक्षा एवं स्कूल फीस',
    'भोजन, कपड़े और दैनिक खर्च',
    'स्वास्थ्य एवं इलाज',
    'रहने की व्यवस्था',
    'देखभाल एवं समय देना',
    'दूसरे अभिभावक के साथ साझा जिम्मेदारी',
    'अन्य व्यवस्था',
  ];

  final Set<String> selectedResponsibilities = {};

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;
    if (data == null) return;

    count = data['childrenCount'] as String?;
    ageGroup = data['childrenAgeGroup'] as String?;
    livingWith = data['childrenLivingWith'] as String?;
    financialResponsibility =
    data['childrenFinancialResponsibility'] as String?;
    careResponsibility =
    data['childrenCareResponsibility'] as String?;
    partnerRole = data['expectedPartnerRole'] as String?;

    selectedResponsibilities.addAll(
      List<String>.from(
        data['childrenResponsibilities'] ?? [],
      ),
    );

    detailsController.text =
        data['childrenDetails']?.toString() ?? '';
  }

  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget dropdown(
      String label,
      String? value,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('बच्चों की जानकारी'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'दूसरी शादी से पहले बच्चों की स्थिति और '
                  'जिम्मेदारियों की स्पष्ट जानकारी देना जरूरी है।',
              style: TextStyle(fontSize: 15),
            ),

            sectionTitle('1. बच्चों की संख्या'),

            dropdown(
              'कुल कितने बच्चे हैं?',
              count,
              ['1', '2', '3', '4 या अधिक'],
                  (v) => setState(() => count = v),
            ),

            sectionTitle('2. बच्चों की आयु'),

            dropdown(
              'आयु-समूह चुनें',
              ageGroup,
              [
                'सभी 18 वर्ष से कम',
                'सभी 18 वर्ष या अधिक',
                'कुछ 18 वर्ष से कम, कुछ 18 वर्ष या अधिक',
              ],
                  (v) => setState(() => ageGroup = v),
            ),

            sectionTitle('3. बच्चे कहाँ रहते हैं?'),

            dropdown(
              'वर्तमान रहने की व्यवस्था',
              livingWith,
              [
                'मेरे साथ',
                'दूसरे अभिभावक के साथ',
                'दादा-दादी या अन्य परिवार के साथ',
                'अलग-अलग व्यवस्था',
                'अन्य व्यवस्था',
              ],
                  (v) => setState(() => livingWith = v),
            ),

            sectionTitle('4. आर्थिक जिम्मेदारियाँ'),

            dropdown(
              'बच्चों का खर्च कौन उठाता है?',
              financialResponsibility,
              [
                'मुख्यतः मैं',
                'मुख्यतः दूसरा अभिभावक',
                'दोनों मिलकर',
                'परिवार के अन्य सदस्य',
                'अलग-अलग जिम्मेदारियाँ',
                'अन्य व्यवस्था',
              ],
                  (v) => setState(
                    () => financialResponsibility = v,
              ),
            ),

            sectionTitle('5. देखभाल की जिम्मेदारी'),

            ...responsibilityOptions.map((item) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item),
                value: selectedResponsibilities.contains(item),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedResponsibilities.add(item);
                    } else {
                      selectedResponsibilities.remove(item);
                    }
                  });
                },
              );
            }),

            dropdown(
              'रोजमर्रा की देखभाल मुख्यतः कौन करता है?',
              careResponsibility,
              [
                'मैं',
                'दूसरा अभिभावक',
                'दोनों मिलकर',
                'परिवार के अन्य सदस्य',
                'अन्य व्यवस्था',
              ],
                  (v) => setState(
                    () => careResponsibility = v,
              ),
            ),

            sectionTitle('6. भावी जीवनसाथी से अपेक्षा'),

            dropdown(
              'आप क्या अपेक्षा रखते हैं?',
              partnerRole,
              [
                'बच्चों के प्रति सम्मान और सहयोग',
                'देखभाल में भी सहयोग',
                'आर्थिक सहयोग भी अपेक्षित है',
                'जिम्मेदारियाँ आपसी सहमति से तय होंगी',
                'बच्चों की जिम्मेदारी मेरी रहेगी',
              ],
                  (v) => setState(() => partnerRole = v),
            ),

            sectionTitle('7. अन्य जरूरी जानकारी (वैकल्पिक)'),

            TextField(
              controller: detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                'बच्चों की पढ़ाई, भविष्य या जिम्मेदारियों '
                    'के बारे में अन्य जरूरी बात लिखें',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('जानकारी सुरक्षित करके लौटें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    <String, dynamic>{
                      'childrenCount': count ?? '',
                      'childrenAgeGroup': ageGroup ?? '',
                      'childrenLivingWith': livingWith ?? '',
                      'childrenFinancialResponsibility':
                      financialResponsibility ?? '',
                      'childrenResponsibilities':
                      selectedResponsibilities.toList(),
                      'childrenCareResponsibility':
                      careResponsibility ?? '',
                      'expectedPartnerRole': partnerRole ?? '',
                      'childrenDetails':
                      detailsController.text.trim(),
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
