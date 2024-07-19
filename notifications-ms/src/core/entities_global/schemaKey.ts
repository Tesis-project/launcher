import { PrimaryKey } from "@mikro-orm/core";

export class Schema_key {

    @PrimaryKey({ type: 'uuid', defaultRaw: 'gen_random_uuid()' })
    _id: string

}