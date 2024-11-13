import React from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useForm, FormProvider } from "react-hook-form";
import { Form, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form";

const SignUp = () => {
  const methods = useForm();

  return (
    <FormProvider {...methods}>
      <Form>
        <h1>Sign Up</h1>
        <Button>GoogleButton</Button>
        <div>OR CONTINUE WITH</div>
        
        <FormItem>
          <FormLabel>Email</FormLabel>
          <FormControl asChild>
            <Input type="email" />
          </FormControl>
          <FormMessage />
        </FormItem>

        <FormItem>
          <FormLabel>Password</FormLabel>
          <FormControl asChild>
            <Input type="password" />
          </FormControl>
          <FormMessage />
        </FormItem>

        <FormItem>
          <FormLabel>Confirm Password</FormLabel>
          <FormControl asChild>
            <Input type="password" />
          </FormControl>
          <FormMessage />
        </FormItem>

        <Button type="submit">Sign Up</Button>
        <small>
          Already have an account? <Link to="/login">Log In</Link>
        </small>
        <p>
          By signing up, you agree to our <Link to="/terms">Terms of Service</Link> and <Link to="/privacy">Privacy Policy</Link>
        </p>
      </Form>
    </FormProvider>
  );
};

export default SignUp;