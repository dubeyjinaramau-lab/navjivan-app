import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''
Terms & Conditions

1. यह ऐप विवाह/पुनर्विवाह के इच्छुक लोगों को एक-दूसरे से जुड़ने का माध्यम प्रदान करता है।

2. उपयोगकर्ता द्वारा दी गई जानकारी की सत्यता की जिम्मेदारी स्वयं उपयोगकर्ता की होगी।

3. किसी भी व्यक्ति से बातचीत, मुलाकात या विवाह संबंधी निर्णय लेने से पहले उचित जांच करना उपयोगकर्ता की जिम्मेदारी होगी।

4. ऐप किसी भी उपयोगकर्ता की जानकारी, व्यवहार या विवाह संबंधी परिणाम की गारंटी नहीं देता।

5. गलत जानकारी, धोखाधड़ी, दुर्व्यवहार या कानून-विरुद्ध गतिविधि पाए जाने पर प्रोफाइल हटाई जा सकती है।

6. निजी संपर्क जानकारी और अन्य संवेदनशील विवरण उपयोगकर्ता की अनुमति और ऐप के नियमों के अनुसार ही साझा किए जाएंगे।

7. इस ऐप का उपयोग करके आप इन नियमों एवं शर्तों से सहमत होते हैं।
''',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}