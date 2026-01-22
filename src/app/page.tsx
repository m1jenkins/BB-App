import Navigation from "@/components/Navigation";
import Hero from "@/components/Hero";
import SaasTrap from "@/components/SaasTrap";
import Solution from "@/components/Solution";
import Services from "@/components/Services";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen">
      <Navigation />
      <Hero />
      <SaasTrap />
      <Solution />
      <Services />
      <Footer />
    </main>
  );
}
