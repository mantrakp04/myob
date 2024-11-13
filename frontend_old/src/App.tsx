import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { ThemeProvider } from "@/components/theme-provider";
import './App.css';
import Login from "./pages/auth/Login";

function App() {
  return (
      <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
        <Router>
          <Routes>
            <Route path="/login" element={<Login />} />
          </Routes>
        </Router>
      </ThemeProvider>
  );
}

export default App;
