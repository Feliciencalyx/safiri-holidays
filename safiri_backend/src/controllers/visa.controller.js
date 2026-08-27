import prisma from '../config/db.js';

/**
 * POST /api/visas/applications
 * Create or evaluate a new visa application case
 */
export async function createVisaApplication(req, res) {
  try {
    const { destinationCountry, applicantNationality, residenceCountry, travelPurpose, userId } = req.body;

    if (!destinationCountry || !applicantNationality) {
      return res.status(400).json({
        success: false,
        message: 'Missing required visa parameters (destinationCountry, applicantNationality)',
      });
    }

    const caseId = `#VSA-${Math.floor(1000 + Math.random() * 8999)}`;
    const initialDocuments = {
      'Passport Scan': true,
      'Proof of Funds': false,
      'Invitation Letter': false,
      'Biometrics Receipt': false,
    };

    if (prisma) {
      const createdCase = await prisma.visaApplication.create({
        data: {
          id: caseId,
          userId: userId || null,
          destinationCountry,
          applicantNationality,
          residenceCountry: residenceCountry || 'Rwanda',
          travelPurpose: travelPurpose || 'Tourism',
          currentStep: 2,
          status: 'Under Review',
          documentsUploaded: initialDocuments,
        },
      });

      return res.status(201).json({
        success: true,
        message: 'Visa application case created and submitted for review',
        visaCase: createdCase,
      });
    } else {
      return res.status(500).json({
        success: false,
        message: 'Database connection unavailable',
      });
    }
  } catch (error) {
    console.error('[VISA CONTROLLER ERROR]', error);
    return res.status(500).json({ success: false, message: 'Failed to create visa application' });
  }
}

/**
 * GET /api/visas/applications/:id
 * Retrieve visa case status & vault documents
 */
export async function getVisaApplication(req, res) {
  try {
    const { id } = req.params;

    if (prisma) {
      const dbCase = await prisma.visaApplication.findUnique({ where: { id } });
      if (dbCase) {
        return res.json({ success: true, visaCase: dbCase });
      }
    }

    return res.status(404).json({
      success: false,
      message: `Visa application case ${id} not found`,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Unable to retrieve visa application details' });
  }
}

/**
 * PUT /api/visas/applications/:id/documents
 * Toggle uploaded document in vault
 */
export async function updateVisaDocument(req, res) {
  try {
    const { id } = req.params;
    const { documentName, isUploaded } = req.body;

    if (prisma) {
      const dbCase = await prisma.visaApplication.findUnique({ where: { id } });
      if (dbCase) {
        const currentDocs = typeof dbCase.documentsUploaded === 'object' ? dbCase.documentsUploaded : {};
        currentDocs[documentName] = isUploaded;

        const updatedDbCase = await prisma.visaApplication.update({
          where: { id },
          data: { documentsUploaded: currentDocs },
        });

        return res.json({ success: true, visaCase: updatedDbCase });
      }
    }

    return res.status(404).json({ success: false, message: `Visa case ${id} not found` });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Failed to update visa document' });
  }
}
