
Table patients {
  patient_id     int [pk, increment]
  first_name     varchar(60) [not null]
  middle_name    varchar(60)
  last_name      varchar(60) [not null]
  maternal_surname varchar(60)
  birth_date     date [not null]
  sex            varchar(10)
  email          varchar(160)
  registered_at  datetime [default: `now()`]
  is_active      boolean [default: true]
}

Table doctors {
  doctor_id            int [pk, increment]
  internal_code        varchar(30)
  license_number       varchar(40) [not null, unique]
  first_names          varchar(120) [not null]
  last_names           varchar(120) [not null]
  professional_email   varchar(160)
  hospital_join_date   date
  specialties_json     json
  is_active            boolean [default: true]
}

Table users {
  user_id    int [pk, increment]
  username   varchar(80)  [not null, unique]
  email      varchar(160) [not null, unique]
  role_name  varchar(60)
  is_active  boolean [default: true]
}


Table patient_identifiers {

  patient_id       int [not null]
  document_type    varchar(16) [not null]
  document_number  varchar(64) [not null]
  issuing_country  varchar(2)  [not null]
  issued_on        date
  indexes {
    (patient_id, document_type, document_number, issuing_country) [pk]
  }
}

Table patient_contacts {

  patient_contact_id int [pk, increment]
  patient_id         int [not null]
  contact_kind       varchar(20) [not null]
  is_primary         boolean [default: false]
  json_detail        json
  note: 'json_detail example for address: {"address_line":"...", "city":"...", "postal_code":"...", "lat":..., "lon":...}'
}

Table doctor_contacts {
  doctor_contact_id int [pk, increment]
  doctor_id         int [not null]
  contact_kind      varchar(20) [not null]
  is_primary        boolean [default: false]
  json_detail       json
}


Table rooms {
  room_id   int [pk, increment]
  name      varchar(80) [not null]
  location  varchar(120)
}

Table doctor_schedules {
  doctor_schedule_id int [pk, increment]
  doctor_id          int [not null]
  weekday            int [not null]
  time_start         time [not null]
  time_end           time [not null]
  modality           varchar(20)
  indexes {
    (doctor_id, weekday, time_start, time_end) [unique]
  }
}

Table appointments {
  appointment_id int [pk, increment]
  patient_id     int [not null]
  doctor_id      int [not null]
  room_id        int
  date           date [not null]
  time_start     time [not null]
  time_end       time [not null]
  visit_type     varchar(40)
  status         varchar(30) [not null]
  reason         varchar(240)
  created_by     int
  created_at     datetime [default: `now()`]
  indexes {
    (doctor_id, date, time_start, time_end)
    (room_id, date, time_start, time_end)
  }
}


Table diagnoses {
  diagnosis_id int [pk, increment]
  icd_code     varchar(12) [not null, unique]
  description  varchar(240) [not null]
}

Table procedures {
  procedure_id    int [pk, increment]
  code            varchar(20) [not null, unique]
  description     varchar(240) [not null]
  reference_price numeric(12,2)
}

Table medications {
  medication_id     int [pk, increment]
  atc_code          varchar(20) [unique]
  trade_name        varchar(160)
  active_ingredient varchar(160)
  presentation      varchar(120)
}

Table clinical_records {
  record_id            int [pk, increment]
  patient_id           int [not null]
  doctor_id            int [not null]
  recorded_at          datetime [not null, default: `now()`]
  record_type          varchar(40)
  summary_text         text
  summary_structured   json
  primary_diagnosis_id int
  note: 'One clinical record per encounter/event'
}

Table record_diagnoses {
  record_id    int [not null]
  diagnosis_id int [not null]
  role_type    varchar(20)
  observation  text
  indexes {
    (record_id, diagnosis_id) [pk]
  }
}

Table record_procedures {
  record_id    int [not null]
  procedure_id int [not null]
  result       varchar(200)
  observation  text
  indexes {
    (record_id, procedure_id) [pk]
  }
}

Table prescriptions {
  prescription_id int [pk, increment]
  record_id       int [not null]
  medication_id   int [not null]
  posology        varchar(160) [not null]
  duration_text   varchar(80)
  instructions    text
}

Table vital_signs {
  vital_sign_id int [pk, increment]
  record_id     int [not null]
  kind          varchar(40) [not null]
  value_text    varchar(40) [not null]
  unit          varchar(16)
  measured_at   datetime [not null, default: `now()`]
  indexes {
    (record_id, measured_at)
  }
}


Table insurers {
  insurer_id int [pk, increment]
  name       varchar(160) [not null, unique]
  contact    varchar(160)
}

Table policies {
  policy_id     int [pk, increment]
  patient_id    int [not null]
  insurer_id    int [not null]
  policy_number varchar(60) [not null]
  coverage_note text
  start_date    date [not null]
  end_date      date [not null]
  status        varchar(20)
  indexes {
    (insurer_id, policy_number) [unique]
  }
}


Table audit_logs {
  audit_id   int [pk, increment]
  user_id    int [not null]
  role_name  varchar(60)
  entity     varchar(80) [not null]
  entity_id  int [not null]
  action     varchar(20) [not null]
  detail     json
  created_at datetime [default: `now()`]
  ip         varchar(64)
  app_name   varchar(80)
}


Ref: patient_identifiers.patient_id > patients.patient_id
Ref: patient_contacts.patient_id > patients.patient_id
Ref: doctor_contacts.doctor_id > doctors.doctor_id


Ref: doctor_schedules.doctor_id > doctors.doctor_id
Ref: appointments.patient_id > patients.patient_id
Ref: appointments.doctor_id > doctors.doctor_id
Ref: appointments.room_id > rooms.room_id
Ref: appointments.created_by > users.user_id


Ref: clinical_records.patient_id > patients.patient_id
Ref: clinical_records.doctor_id > doctors.doctor_id
Ref: clinical_records.primary_diagnosis_id > diagnoses.diagnosis_id
Ref: record_diagnoses.record_id > clinical_records.record_id
Ref: record_diagnoses.diagnosis_id > diagnoses.diagnosis_id
Ref: record_procedures.record_id > clinical_records.record_id
Ref: record_procedures.procedure_id > procedures.procedure_id
Ref: prescriptions.record_id > clinical_records.record_id
Ref: prescriptions.medication_id > medications.medication_id
Ref: vital_signs.record_id > clinical_records.record_id


Ref: policies.patient_id > patients.patient_id
Ref: policies.insurer_id > insurers.insurer_id


Ref: audit_logs.user_id > users.user_id
