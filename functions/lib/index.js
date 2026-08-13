"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTrainerEnrollment = exports.createMemberEnrollment = void 0;
const app_1 = require("firebase-admin/app");
(0, app_1.initializeApp)();
var memberEnrollment_1 = require("./memberEnrollment");
Object.defineProperty(exports, "createMemberEnrollment", { enumerable: true, get: function () { return memberEnrollment_1.createMemberEnrollment; } });
var trainerEnrollment_1 = require("./trainerEnrollment");
Object.defineProperty(exports, "createTrainerEnrollment", { enumerable: true, get: function () { return trainerEnrollment_1.createTrainerEnrollment; } });
//# sourceMappingURL=index.js.map