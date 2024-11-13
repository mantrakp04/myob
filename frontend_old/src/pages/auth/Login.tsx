import React from 'react';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { useForm } from 'react-hook-form';
import { FcGoogle } from 'react-icons/fc';

function Login() {
  const { register, handleSubmit, formState: { errors } } = useForm();

  const onSubmit = (data: any) => {
    // Handle login
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background/95 dark:bg-background">
      <div className="w-full max-w-md space-y-8 rounded-lg border border-border/5 bg-background/50 p-8 shadow-premium backdrop-blur">
        <div className="space-y-2">
          <h1 className="text-3xl font-semibold tracking-tight">Welcome Back</h1>
          <p className="text-sm text-muted-foreground">Sign in to your account</p>
        </div>

        <Button variant="outline" className="w-full bg-background/95 hover:bg-accent/80">
          <FcGoogle className="mr-2 h-5 w-5" />
          Continue with Google
        </Button>

        <div className="relative flex items-center">
          <div className="flex-grow border-t border-border/30"></div>
          <span className="mx-4 flex-shrink text-xs text-muted-foreground">or continue with</span>
          <div className="flex-grow border-t border-border/30"></div>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          <div className="space-y-2">
            <label className="text-sm font-medium text-foreground">
              Email
            </label>
            <Input
              type="email"
              placeholder="you@example.com"
              className="bg-background/50"
              {...register('email', { required: 'Email is required' })}
            />
            {errors.email && (
              <p className="text-xs text-destructive">{errors.email.message}</p>
            )}
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium text-foreground">
                Password
              </label>
              <a 
                href="/forgot-password" 
                className="text-xs text-primary hover:text-primary/90"
              >
                Forgot password?
              </a>
            </div>
            <Input
              type="password"
              placeholder="••••••••"
              className="bg-background/50"
              {...register('password', { required: 'Password is required' })}
            />
            {errors.password && (
              <p className="text-xs text-destructive">{errors.password.message}</p>
            )}
          </div>

          <Button type="submit" className="w-full">
            Sign In
          </Button>
        </form>

        <p className="text-center text-sm text-muted-foreground">
          Don't have an account?{' '}
          <a href="/sign-up" className="text-primary hover:text-primary/90">
            Sign up
          </a>
        </p>
      </div>
    </div>
  );
}

export default Login;
