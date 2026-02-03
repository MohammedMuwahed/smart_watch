import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// import other services if needed, e.g. getFirestore, getAuth

const firebaseConfig = {
  apiKey: "AIzaSyBPaGoBQlPZwxdO3QDA7JGUr-jZUviLCyM",
  authDomain: "smartwatch-university-project.firebaseapp.com",
  projectId: "smartwatch-university-project",
  storageBucket: "smartwatch-university-project.firebasestorage.app",
  messagingSenderId: "275982759255",
  appId: "1:275982759255:web:46c4e7a46ea76ebbc43a12",
  measurementId: "G-XM37SJ8XWC",
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

export { app, analytics };