import SwiftUI

public struct ReportCorrectionSheet: View {
    @EnvironmentObject private var store: PhonebookStore
    @Environment(\.dismiss) private var dismiss

    @State private var issueType: String = "incorrect_phone"
    @State private var suggestedPhone: String = ""
    @State private var details: String = ""
    @State private var reporterName: String = ""
    @State private var reporterPhone: String = ""

    @State private var isSubmitting: Bool = false
    @State private var submissionError: String? = nil

    private let issueTypes = [
        ("incorrect_phone", "Incorrect / Inactive Phone Number"),
        ("name_spelling", "Name Spelling Error"),
        ("term_expired", "No longer in office / Term ended"),
        ("wrong_village", "Wrong Village / Designation"),
        ("other", "Other Correction")
    ]

    public var body: some View {
        NavigationStack {
            Form {
                // Section: Target Info
                Section(header: Text("Reporting Target")) {
                    if let contact = store.reportTargetContact {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contact.name)
                                .font(.headline)
                            Text("\(contact.designation) • \(contact.villageName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Current Phone: \(contact.phone)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if let staff = store.reportTargetStaff, let off = store.reportTargetOffice {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(staff.name)
                                .font(.headline)
                            Text("\(staff.designation) • \(off.name)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Current Phone: \(staff.phone)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else if let em = store.reportTargetEmergency {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(em.service)
                                .font(.headline)
                            Text(em.officer ?? "Emergency Service")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Current Phone: \(em.phone)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Section: Issue Type
                Section(header: Text("Issue Type")) {
                    Picker("Issue Type", selection: $issueType) {
                        ForEach(issueTypes, id: \.0) { item in
                            Text(item.1).tag(item.0)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Section: Suggested Correction
                Section(header: Text("Suggested Update")) {
                    TextField("Suggested Correct Phone Number", text: $suggestedPhone)
                        .keyboardType(.phonePad)

                    TextField("Correction details / notes...", text: $details, axis: .vertical)
                        .lineLimit(3...6)
                }

                // Section: Reporter Information
                Section(header: Text("Your Details (Optional)"), footer: Text("Information will be reviewed directly by the District Administration.")) {
                    TextField("Your Name (Citizen / Resident)", text: $reporterName)
                    TextField("Your Phone (for verification)", text: $reporterPhone)
                        .keyboardType(.phonePad)
                }

                if let error = submissionError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Report Correction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        submitReport()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func submitReport() {
        isSubmitting = true
        submissionError = nil

        let payload: ReportPayload
        if let contact = store.reportTargetContact {
            payload = ReportPayload(
                contactId: contact.id,
                contactName: contact.name,
                serviceName: contact.name,
                villageName: contact.villageName,
                designation: contact.designation,
                isEmergency: false,
                isOffice: false,
                issueType: issueType,
                suggestedPhone: suggestedPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                description: details.trimmingCharacters(in: .whitespacesAndNewlines),
                reportedBy: reporterName.isEmpty ? "Citizen" : reporterName,
                reporterPhone: reporterPhone,
                district: store.selectedDistrict
            )
        } else if let staff = store.reportTargetStaff, let off = store.reportTargetOffice {
            payload = ReportPayload(
                contactId: staff.id,
                contactName: staff.name,
                serviceName: staff.name,
                villageName: off.name,
                designation: "\(staff.designation) (\(off.name))",
                isEmergency: false,
                isOffice: true,
                officeName: off.name,
                staffId: staff.id,
                issueType: issueType,
                suggestedPhone: suggestedPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                description: details.trimmingCharacters(in: .whitespacesAndNewlines),
                reportedBy: reporterName.isEmpty ? "Citizen" : reporterName,
                reporterPhone: reporterPhone,
                district: store.selectedDistrict
            )
        } else if let em = store.reportTargetEmergency {
            payload = ReportPayload(
                contactId: em.id,
                contactName: em.service,
                serviceName: em.service,
                villageName: "\(store.selectedDistrict) Emergency Services",
                designation: em.officer ?? "Emergency Service",
                isEmergency: true,
                isOffice: false,
                issueType: issueType,
                suggestedPhone: suggestedPhone.trimmingCharacters(in: .whitespacesAndNewlines),
                description: details.trimmingCharacters(in: .whitespacesAndNewlines),
                reportedBy: reporterName.isEmpty ? "Citizen" : reporterName,
                reporterPhone: reporterPhone,
                district: store.selectedDistrict
            )
        } else {
            isSubmitting = false
            dismiss()
            return
        }

        Task {
            do {
                let success = try await APIService.shared.submitReport(payload)
                isSubmitting = false
                if success {
                    dismiss()
                    store.showToast("✅ Report submitted to District Admin")
                } else {
                    submissionError = "Failed to submit report. Please try again."
                }
            } catch {
                isSubmitting = false
                submissionError = "Network error. Please check your connection."
            }
        }
    }
}
