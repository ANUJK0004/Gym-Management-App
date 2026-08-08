// functions/src/index.ts

import { initializeApp } from "firebase-admin/app";

initializeApp();

export {
  createMemberEnrollment,
} from "./memberEnrollment";