CREATE TABLE "auth" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"email" VARCHAR(255) NOT NULL,
	"password" VARCHAR(255) NOT NULL,
	"username" VARCHAR(255) NULL DEFAULT NULL,
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-20 13:31:47+00',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-20 13:31:47+00',
	"last_session" TIMESTAMPTZ NULL DEFAULT NULL,
	"status" TEXT NOT NULL DEFAULT 'PENDING',
	"role" TEXT NOT NULL DEFAULT 'ARTIST_ROLE',
	"user" VARCHAR(255) NOT NULL,
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "auth_email_unique" ("email"),
	UNIQUE INDEX "auth_username_unique" ("username"),
	UNIQUE INDEX "auth_user_unique" ("user"),
	CONSTRAINT "auth_status_check" CHECK (((status = ANY (ARRAY['NONE'::text, 'VERIFIED'::text, 'NOT'::text, 'BLOCKED'::text, 'DELETED'::text, 'SUSPENDED'::text, 'PENDING'::text, 'ACTIVE'::text, 'INACTIVE'::text])))),
	CONSTRAINT "auth_role_check" CHECK (((role = ANY (ARRAY['ARTIST_ROLE'::text, 'CONTRATIST_ROLE'::text, 'ADMIN_ROLE'::text]))))
);

CREATE TABLE "auth_requests" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"key" VARCHAR(255) NOT NULL,
	"type" TEXT NOT NULL,
	"status" TEXT NOT NULL DEFAULT 'PENDING',
	"detail" VARCHAR(255) NULL DEFAULT NULL,
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-20 13:31:47+00',
	"used_at" TIMESTAMPTZ NULL DEFAULT NULL,
	"auth__id" UUID NULL DEFAULT NULL,
	PRIMARY KEY ("_id"),
	CONSTRAINT "auth_requests_auth__id_foreign" FOREIGN KEY ("auth__id") REFERENCES "auth" ("_id") ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT "auth_requests_type_check" CHECK (((type = ANY (ARRAY['CONFIRM_ACCOUNT'::text, 'RESET_PASSWORD'::text, 'CHANGE_EMAIL'::text])))),
	CONSTRAINT "auth_requests_status_check" CHECK (((status = ANY (ARRAY['PENDING'::text, 'USED'::text, 'EXPIRED'::text]))))
);

CREATE TABLE "user" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"name" VARCHAR(255) NOT NULL,
	"last_name" VARCHAR(255) NOT NULL,
	"gender" TEXT NOT NULL DEFAULT 'NONE',
	"phone" VARCHAR(255) NULL DEFAULT NULL,
	"direction" JSONB NULL DEFAULT NULL,
	"auth" VARCHAR(255) NOT NULL,
	"profile" VARCHAR(255) NOT NULL,
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-12 06:19:40+00',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "user_auth_unique" ("auth"),
	UNIQUE INDEX "user_profile_unique" ("profile"),
	CONSTRAINT "user_gender_check" CHECK (((gender = ANY (ARRAY['MALE'::text, 'FEMALE'::text, 'NONE'::text]))))
);

CREATE TABLE "user_bank_data" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"type" TEXT NOT NULL,
	"bank_name" TEXT NOT NULL,
	"number" VARCHAR(255) NOT NULL,
	"titular" VARCHAR(255) NOT NULL,
	"person_id" VARCHAR(255) NOT NULL,
	"phone" VARCHAR(255) NOT NULL,
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-12 06:19:40+00',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-12 06:19:40+00',
	"hiring_data__id" UUID NULL DEFAULT NULL,
	PRIMARY KEY ("_id"),
	CONSTRAINT "user_bank_data_hiring_data__id_foreign" FOREIGN KEY ("hiring_data__id") REFERENCES "user_hiring_data" ("_id") ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT "user_bank_data_type_check" CHECK (((type = ANY (ARRAY['BANK_ACCOUNT'::text, 'MOBILE_PAYMENT'::text])))),
	CONSTRAINT "user_bank_data_bank_name_check" CHECK (((bank_name = ANY (ARRAY['BC_BICENTENARIO'::text, 'BC_BANESCO'::text, 'BC_TESORO'::text, 'BC_PROVINCIAL'::text, 'BC_MERCANTIL'::text, 'BC_VENEZUELA'::text]))))
);

CREATE TABLE "user_hiring_data" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"user__id" UUID NULL DEFAULT NULL,
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "user_hiring_data_user__id_unique" ("user__id"),
	CONSTRAINT "user_hiring_data_user__id_foreign" FOREIGN KEY ("user__id") REFERENCES "user" ("_id") ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "user_personal_data" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"address" VARCHAR(255) NULL DEFAULT '',
	"city" VARCHAR(255) NULL DEFAULT '',
	"phone" VARCHAR(255) NULL DEFAULT '',
	"postal_code" VARCHAR(255) NULL DEFAULT '',
	"rif" VARCHAR(255) NULL DEFAULT '',
	"social_reason" VARCHAR(255) NULL DEFAULT '',
	"state" VARCHAR(255) NULL DEFAULT '',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-12 06:19:40+00',
	"hiring_data__id" UUID NULL DEFAULT NULL,
	"specific_conditions" VARCHAR(255) NULL DEFAULT '',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "user_personal_data_hiring_data__id_unique" ("hiring_data__id"),
	CONSTRAINT "user_personal_data_hiring_data__id_foreign" FOREIGN KEY ("hiring_data__id") REFERENCES "user_hiring_data" ("_id") ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "profile" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"artistic_name" VARCHAR(255) NULL DEFAULT NULL,
	"bio_short" VARCHAR(255) NULL DEFAULT NULL,
	"profile_pic" JSONB NULL DEFAULT NULL,
	"cover_pic" JSONB NULL DEFAULT NULL,
	"credentials" JSONB NULL DEFAULT '{"identity_file": {}, "profesional_file": {}}',
	"media" JSONB NULL DEFAULT '{"image_gallery": [], "video_gallery": []}',
	"socials" JSONB NULL DEFAULT '{"tiktok": "", "twitter": "", "youtube": "", "facebook": "", "instagram": ""}',
	"user" VARCHAR(255) NOT NULL,
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-27 08:19:57+00',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "profile_user_unique" ("user")
);

CREATE TABLE "profile_meta_role" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"profile__id" UUID NULL DEFAULT NULL,
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "profile_meta_role_profile__id_unique" ("profile__id"),
	CONSTRAINT "profile_meta_role_profile__id_foreign" FOREIGN KEY ("profile__id") REFERENCES "profile" ("_id") ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "user_meta_artist" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"skills" JSONB NOT NULL DEFAULT '{"singer": {"voice_type": [], "voice_specialty": []}, "instrumentist": {"position": [], "specialty": [], "categories": []}, "scenes_director": {"specialty": [], "repertoire": []}, "orquests_director": {"specialty": [], "repertoire": []}}',
	"meta_role__id" UUID NULL DEFAULT NULL,
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-27 08:19:57+00',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "user_meta_artist_meta_role__id_unique" ("meta_role__id"),
	CONSTRAINT "user_meta_artist_meta_role__id_foreign" FOREIGN KEY ("meta_role__id") REFERENCES "profile_meta_role" ("_id") ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "user_meta_contratist" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"institutes_companies" JSONB NOT NULL DEFAULT '{"name": "", "phone": "", "rif_nif": "", "position": "", "direction": {"city": "", "state": "", "address": ""}}',
	"meta_role__id" UUID NULL DEFAULT NULL,
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-27 08:19:57+00',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "user_meta_contratist_meta_role__id_unique" ("meta_role__id"),
	CONSTRAINT "user_meta_contratist_meta_role__id_foreign" FOREIGN KEY ("meta_role__id") REFERENCES "profile_meta_role" ("_id") ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "media" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"file" VARCHAR(255) NOT NULL,
	"folder" VARCHAR(255) NOT NULL,
	"type" TEXT NOT NULL,
	"format" TEXT NOT NULL,
	"src" VARCHAR(255) NOT NULL,
	"reference" TEXT NOT NULL,
	"reference_id" VARCHAR(255) NOT NULL,
	"user" VARCHAR(255) NOT NULL,
	"cloud_file_id" VARCHAR(255) NULL DEFAULT NULL,
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-02 10:38:15+00',
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "media_cloud_file_id_unique" ("cloud_file_id"),
	CONSTRAINT "media_type_check" CHECK (((type = ANY (ARRAY['IMAGE'::text, 'VIDEO'::text, 'DOCUMENT'::text])))),
	CONSTRAINT "media_format_check" CHECK (((format = ANY (ARRAY['JPG'::text, 'JPEG'::text, 'PNG'::text, 'MP4'::text, 'PDF'::text, 'DOC'::text, 'DOCX'::text])))),
	CONSTRAINT "media_reference_check" CHECK (((reference = ANY (ARRAY['PROFILE_PROFILE_PIC'::text, 'PROFILE_COVER_PIC'::text, 'PROFILE_CREDENTIALS_IDENTITY'::text, 'PROFILE_CREDENTIALS_PROFESSIONAL'::text, 'PROFILE_MEDIA_VIDEO_GALLERY'::text, 'PROFILE_MEDIA_IMAGE_GALLERY'::text, 'VACANT_PIC'::text, 'VACANT_CONTRACT_DOCUMENT'::text]))))
);

CREATE TABLE "notifications" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"subject" VARCHAR(255) NOT NULL,
	"message" VARCHAR(255) NOT NULL,
	"state" TEXT NOT NULL DEFAULT 'UNREAD',
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-19 17:30:47+00',
	"read_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-07-19 17:30:47+00',
	"user" VARCHAR(255) NOT NULL,
	PRIMARY KEY ("_id"),
	CONSTRAINT "notifications_state_check" CHECK (((state = ANY (ARRAY['READ'::text, 'UNREAD'::text]))))
);

CREATE TABLE "contracts" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"contratist" JSONB NOT NULL,
	"contractor" JSONB NOT NULL,
	"details" JSONB NULL DEFAULT NULL,
	"status" TEXT NOT NULL DEFAULT 'PLANNING',
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"vacant__id" UUID NULL DEFAULT NULL,
	PRIMARY KEY ("_id"),
	UNIQUE INDEX "contracts_vacant__id_unique" ("vacant__id"),
	CONSTRAINT "contracts_vacant__id_foreign" FOREIGN KEY ("vacant__id") REFERENCES "vacants" ("_id") ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT "contracts_status_check" CHECK (((status = ANY (ARRAY['PLANNING'::text, 'SINGS_PENDING'::text, 'IN_PROGRESS'::text, 'CANCELLED'::text, 'COMPLETED'::text]))))
);

CREATE TABLE "postulations" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"comment" TEXT NULL DEFAULT NULL,
	"status" TEXT NOT NULL DEFAULT 'SENDED',
	"owner_comment" TEXT NULL DEFAULT NULL,
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"vacant__id" UUID NULL DEFAULT NULL,
	"user_postulate" VARCHAR(255) NOT NULL,
	PRIMARY KEY ("_id"),
	CONSTRAINT "postulations_vacant__id_foreign" FOREIGN KEY ("vacant__id") REFERENCES "vacants" ("_id") ON UPDATE CASCADE ON DELETE CASCADE,
	CONSTRAINT "postulations_status_check" CHECK (((status = ANY (ARRAY['SENDED'::text, 'ON_HOLD'::text, 'ACCEPTED'::text, 'CONTRACT_SENT'::text, 'REFUSED'::text]))))
);

CREATE TABLE "vacants" (
	"_id" UUID NOT NULL DEFAULT gen_random_uuid(),
	"vacant_pic" JSONB NULL DEFAULT NULL,
	"title" VARCHAR(255) NOT NULL,
	"desc" TEXT NOT NULL,
	"status" TEXT NOT NULL DEFAULT 'OPEN',
	"created_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"updated_at" TIMESTAMPTZ NOT NULL DEFAULT '2024-09-13 11:15:56+00',
	"operation" JSONB NOT NULL DEFAULT '{"end_at": "", "start_at": ""}',
	"role_desc" TEXT NOT NULL,
	"role_type" JSONB NOT NULL DEFAULT '["SINGER"]',
	"transport_service" JSONB NULL DEFAULT NULL,
	"housing_service" JSONB NULL DEFAULT NULL,
	"vacant_costs" JSONB NULL DEFAULT NULL,
	"vacant_payment" JSONB NOT NULL DEFAULT '{"total": 0, "currency": "USD"}',
	"direction" JSONB NULL DEFAULT NULL,
	"specific_conditions" TEXT NULL DEFAULT NULL,
	"owner" VARCHAR(255) NOT NULL,
	PRIMARY KEY ("_id"),
	CONSTRAINT "vacants_status_check" CHECK (((status = ANY (ARRAY['OPEN'::text, 'CLOSED'::text, 'EXPIRED'::text, 'INPROGRESS'::text]))))
);
