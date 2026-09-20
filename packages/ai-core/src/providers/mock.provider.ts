import { AIProvider, GenerateRequest, GenerateResponse } from './ai-provider.interface';

export class MockProvider implements AIProvider {
  name = 'mock';

  async generateContent(request: GenerateRequest): Promise<GenerateResponse> {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 600));

    let text = 'This is a mocked AI response.';

    // Moderation
    if (request.systemInstruction?.includes('moderate') || request.systemInstruction?.includes('moderator')) {
      if (request.prompt.toLowerCase().includes('violation')) {
        text = JSON.stringify({ isApproved: false, reason: 'Contains violation keyword in mock test' });
      } else {
        text = JSON.stringify({ isApproved: true, reason: 'Looks good' });
      }
    }
    // Voice command
    else if (request.systemInstruction?.includes('Voice') || request.prompt.toLowerCase().includes('voice')) {
      const promptLower = request.prompt.toLowerCase();
      if (promptLower.includes('scheme') || promptLower.includes('योजना') || promptLower.includes('शेतकरी')) {
        text = JSON.stringify({
          action: 'OPEN_SCHEME',
          path: '/schemes',
          language: promptLower.includes('योजना') ? 'hi' : (promptLower.includes('शेतकरी') ? 'mr' : 'en'),
          speechResponse: 'Opening schemes list.',
          entities: { target: 'schemes' }
        });
      } else if (promptLower.includes('organic') || promptLower.includes('farming') || promptLower.includes('शिकायची')) {
        text = JSON.stringify({
          action: 'SEARCH',
          path: '/learning',
          searchQuery: 'organic farming',
          language: promptLower.includes('शिकायची') ? 'mr' : 'en',
          speechResponse: 'Searching for organic farming courses.',
          entities: { target: 'organic farming' }
        });
      } else {
        text = JSON.stringify({
          action: 'UNKNOWN',
          language: 'en',
          speechResponse: 'Could you please repeat that?',
          entities: {}
        });
      }
    }
    // Scheme recommendation
    else if (request.systemInstruction?.includes('government schemes') || request.systemInstruction?.includes('Indian government scheme')) {
      const promptLower = request.prompt.toLowerCase();
      const isFarmer = promptLower.includes('farmer') || promptLower.includes('agriculture');
      const isMaharashtra = promptLower.includes('maharashtra');

      text = JSON.stringify({
        recommendations: [
          {
            schemeName: isFarmer ? 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)' : 'PM Employment Generation Programme (PMEGP)',
            category: isFarmer ? 'AGRICULTURE' : 'MSME',
            ministry: isFarmer ? 'Ministry of Agriculture & Farmers Welfare' : 'Ministry of MSME',
            shortDescription: isFarmer
              ? 'Direct income support of ₹6,000 per year to small and marginal farmer families.'
              : 'Credit-linked subsidy scheme for setting up new micro-enterprises in rural and urban areas.',
            source: 'AI_DISCOVERED',
            potentialMatch: true,
            reasons: isFarmer
              ? ['You identified as a farmer', 'Central scheme available across all states', 'Annual income within eligible range']
              : ['You identified as an entrepreneur', `State of ${isMaharashtra ? 'Maharashtra' : 'your state'} has strong MSME support`, 'Income within project cost limits'],
            officialUrl: isFarmer ? 'https://pmkisan.gov.in' : 'https://www.kviconline.gov.in/pmegpeportal',
            confidence: 0.92
          },
          {
            schemeName: isFarmer ? 'Pradhan Mantri Fasal Bima Yojana (PMFBY)' : 'Stand-Up India Scheme',
            category: isFarmer ? 'AGRICULTURE' : 'ENTREPRENEURSHIP',
            ministry: isFarmer ? 'Ministry of Agriculture & Farmers Welfare' : 'Department of Financial Services',
            shortDescription: isFarmer
              ? 'Crop insurance scheme providing financial support to farmers suffering crop loss/damage.'
              : 'Facilitates bank loans between ₹10 lakh to ₹1 crore for SC/ST and women entrepreneurs.',
            source: 'AI_DISCOVERED',
            potentialMatch: true,
            reasons: isFarmer
              ? ['Crop insurance is highly recommended for all active farmers', 'Low premium rates subsidized by government', 'Covers all types of crop losses']
              : ['Entrepreneur profile matches scheme target group', 'Provides both term loans and working capital', 'No collateral requirement for first-time borrowers'],
            officialUrl: isFarmer ? 'https://pmfby.gov.in' : 'https://www.standupmitra.in',
            confidence: 0.85
          },
          {
            schemeName: 'Pradhan Mantri Mudra Yojana (PMMY)',
            category: 'FINANCE',
            ministry: 'Ministry of Finance',
            shortDescription: 'Provides loans up to ₹10 lakhs to non-corporate, non-farm small/micro enterprises.',
            source: 'AI_DISCOVERED',
            potentialMatch: true,
            reasons: ['Suitable for small business or farming enterprise growth', 'Available through all public sector banks', 'No collateral required for Shishu and Kishor categories'],
            officialUrl: 'https://www.mudra.org.in',
            confidence: 0.80
          }
        ]
      });
    }
    // Scheme details
    else if (request.systemInstruction?.includes('details for this Indian government scheme') || request.systemInstruction?.includes('comprehensive details')) {
      const schemeName = request.prompt.includes('"') ? request.prompt.split('"')[1] : 'Government Scheme';
      text = JSON.stringify({
        schemeName,
        category: 'MSME',
        ministry: 'Ministry of MSME',
        overview: `${schemeName} is an important Indian government scheme designed to support rural entrepreneurs and farmers. It provides financial assistance and technical support to eligible beneficiaries across India.`,
        benefits: [
          'Financial subsidy up to 35% of project cost in rural areas',
          'Credit-linked support through nationalized banks',
          'Technical training and skill development assistance',
          'Priority sector lending benefits'
        ],
        eligibilityCriteria: [
          'Indian citizen above 18 years of age',
          'No existing loan default on any bank',
          'New enterprise (not for expansion of existing unit)',
          'Educational qualification as per scheme guidelines'
        ],
        requiredDocuments: [
          'Aadhaar Card',
          'PAN Card',
          'Address proof',
          'Educational certificates',
          'Project report/business plan',
          'Bank account details'
        ],
        applicationProcess: 'Apply online through the official government portal or visit your nearest bank branch. Submit the required documents along with the application form.',
        officialUrl: 'https://myscheme.gov.in',
        applicationUrl: 'https://myscheme.gov.in',
        targetGroups: ['Farmers', 'Rural entrepreneurs', 'Small business owners', 'Women entrepreneurs']
      });
    }
    // Scheme explanation
    else if (request.systemInstruction?.includes('explaining why a government scheme')) {
      const lines = request.prompt.split('\n');
      const schemeLine = lines[0] || '';
      const schemeName = schemeLine.replace('Scheme:', '').trim();
      text = `This scheme is recommended for you because your profile closely matches the target beneficiary group. Given your activity and location, you are likely to meet the primary eligibility criteria. We recommend reviewing the official scheme guidelines and consulting your nearest Common Service Centre (CSC) for verification.`;
    }

    return {
      text,
      usageMetadata: {
        promptTokenCount: request.prompt.length,
        candidatesTokenCount: text.length,
        totalTokenCount: request.prompt.length + text.length,
      }
    };
  }
}
