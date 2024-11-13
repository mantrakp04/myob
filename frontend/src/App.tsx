import { ThemeProvider } from "@/components/theme-provider";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import SignUp from "./pages/auth/SignUp";
// import Home from "./pages/Home";
// import About from "./pages/About";

function App() {
  return (
    <ThemeProvider defaultTheme="dark" storageKey="vite-ui-theme">
      <Router>
        <Switch>
          <Route path="/signup" component={SignUp} />
          {/* <Route exact path="/" component={Home} />
          <Route path="/about" component={About} /> */}
        </Switch>
      </Router>
    </ThemeProvider>
  );
}

export default App;
