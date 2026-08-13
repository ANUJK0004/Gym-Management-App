import { initializeApp } from "firebase-admin/app";

initializeApp();

export {
  createMemberEnrollment,
} from "./memberEnrollment";

export {
  createTrainerEnrollment,
} from "./trainerEnrollment";