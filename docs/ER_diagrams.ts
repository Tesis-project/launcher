
interface SchemaKey_I {
    _id: string;
}

interface File_Model_I {

}

export enum AuthStatus_Enum {
    NONE = "NONE",
    VERIFIED = "VERIFIED",
    NOT = "NOT",
    BLOCKED = "BLOCKED",
    DELETED = "DELETED",
    SUSPENDED = "SUSPENDED",
    PENDING = "PENDING",
    ACTIVE = "ACTIVE",
    INACTIVE = "INACTIVE",
}

interface Auth_I extends SchemaKey_I {

    email: string;
    password: string;
    username: string;

    created_at: Date;
    updated_at: Date;
    last_session: Date;

    status?: AuthStatus_Enum;

}

export interface User_I extends SchemaKey_I{
    name: string;
    last_name: string;
    gender?: string;
    phone?: string;
    direction?: {
        adress?: string;
        city?: string;
        state?: string;
    }
    auth?: Auth_I;
    profile?: User_Profile_I;
    hiring_data?: User_HiringData_I;
}

 export interface User_Profile_I extends SchemaKey_I {
    artistic_name: string;
    bio_short: string;
    profile_pic: File_Model_I;
    cover_pic: File_Model_I;
    credentials: {
        identity_file?: File_Model_I;
        profesional_file?: File_Model_I;
    };
    media: {
        image_gallery?: File_Model_I[];
        video_gallery?: File_Model_I[];
    };
    socials: {
        facebook?: string;
        twitter?: string;
        instagram?: string;
        youtube?: string;
        tiktok?: string;
    };
    user?: User_I;
}

export interface User_HiringData_I extends SchemaKey_I {
    personal: {
        address?: string;
        city?: string;
        phone?: string;
        postal_code?: string;
        rif?: string;
        social_reason?: string;
        state?: string;
    };
    payment_accounts?: Payment_Account_I[]
}

enum Banks_Enum {
    BC_BICENTENARIO = "BC_BICENTENARIO",
    BC_BANESCO = "BC_BANESCO",
    BC_TESORO = "BC_TESORO",
    BC_PROVINCIAL = "BC_PROVINCIAL",
    BC_MERCANTIL = "BC_MERCANTIL",
    BC_VENEZUELA = "BC_VENEZUELA",
}

enum Payment_Type_Enum {
    BANK_ACCOUNT = "BANK_ACCOUNT",
    MOBILE_PAYMENT = "MOBILE_PAYMENT",
}

export interface Payment_Account_I {
    type: Payment_Type_Enum;
    bank_name: Banks_Enum;
    number: string;
    titular: string;
    person_id: string;
    phone: string;
    date: string
}


