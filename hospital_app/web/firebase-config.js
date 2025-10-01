// Firebase configuration for web
// This is a placeholder configuration - replace with actual Firebase project config
const firebaseConfig = {
  apiKey: "demo-api-key",
  authDomain: "hospital-app-demo.firebaseapp.com",
  projectId: "hospital-app-demo",
  storageBucket: "hospital-app-demo.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};

// Initialize Firebase
import { initializeApp } from 'firebase/app';
const app = initializeApp(firebaseConfig);