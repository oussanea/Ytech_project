import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

export default function Home() {
  const team = ["Meriem ASSADI", "Asmaa ELKOURTI", "Chaymae TARIQ", "Sara OUSSANEA", "Raja JARFANI"];

  return (
    <Layout title="Ytech Solutions | Cybersecurity Project">
      {/* Hero Section */}
      <header style={{
        padding: '100px 20px',
        textAlign: 'center',
        background: 'linear-gradient(135deg, #0f0c29 0%, #302b63 50%, #24243e 100%)',
        color: 'white',
        borderBottom: '5px solid #E6E6FA'
      }}>
        <div className="container">
          <h1 style={{fontSize: '4.5rem', fontWeight: '900', color: '#E6E6FA', textShadow: '0 0 20px rgba(230, 230, 250, 0.3)'}}>
            YTECH SOLUTIONS
          </h1>
          <p style={{fontSize: '1.2rem', color: '#A29BFE', letterSpacing: '5px', textTransform: 'uppercase', fontWeight: 'bold'}}>
            Infrastructure Réseau & Sécurité Informatique
          </p>
          <div style={{marginTop: '40px'}}>
            <Link className="button button--lg" to="/docs/PagedeGarde" style={{
                backgroundColor: '#E6E6FA',
                color: '#1a1a2e',
                padding: '15px 45px',
                fontWeight: '900',
                borderRadius: '4px',
                border: 'none'
              }}>
              DÉCOUVRIR LE PROJET ⚡
            </Link>
          </div>
        </div>
      </header>

      {/* Team Section */}
      <main style={{padding: '80px 0', background: '#0f0c29'}}>
        <div className="container">
          <div style={{textAlign: 'center', marginBottom: '50px'}}>
            <h2 style={{fontSize: '2.5rem', color: '#E6E6FA', textTransform: 'uppercase', letterSpacing: '2px'}}>L'Équipe de Projet</h2>
          </div>

          <div className="row" style={{justifyContent: 'center', gap: '15px'}}>
            {team.map((name) => (
              <div key={name} className="col col--2" style={{
                background: 'rgba(230, 230, 250, 0.05)',
                padding: '25px 10px',
                borderRadius: '10px',
                textAlign: 'center',
                border: '1px solid rgba(230, 230, 250, 0.2)',
                boxShadow: '0 10px 30px rgba(0,0,0,0.3)'
              }}>
                <h3 style={{color: '#E6E6FA', fontSize: '2rem', fontWeight: '800', margin: 0}}>
                  {name}
                </h3>
              </div>
            ))}
          </div>

          {/* Mission Section - Matched with PDF text */}
          <div style={{
            marginTop: '100px',
            background: 'rgba(230, 230, 250, 0.95)',
            padding: '60px',
            borderRadius: '5px',
            color: '#0f0c29',
            boxShadow: '20px 20px 0px #7B68EE'
          }}>
            <h2 style={{fontWeight: '900', fontSize: '2.8rem', marginBottom: '20px'}}>Executive Summary</h2>
            <p style={{fontSize: '1.25rem', lineHeight: '1.7', fontWeight: '500'}}>
              Le présent projet s'inscrit dans le cadre de la transformation digitale et sécuritaire de <strong>Ytech Solutions</strong>. 
              Face à une croissance commerciale soutenue, l'entreprise se trouve confrontée à la nécessité impérieuse de revoir intégralement son infrastructure informatique.
            </p>
            <p style={{fontSize: '1.25rem', lineHeight: '1.7', fontWeight: '500'}}>
              L'objectif principal est de concevoir et déployer une <strong>infrastructure réseau sécurisée, fiable et évolutive</strong>, capable de garantir la protection des actifs informationnels critiques (données RH, code source) conformément à la norme <strong>ISO 27001</strong>.
            </p>
          </div>
        </div>
      </main>

      <footer style={{padding: '60px', textAlign: 'center', background: '#050508', color: '#E6E6FA', borderTop: '1px solid #302b63'}}>
        <p style={{opacity: 0.5, letterSpacing: '2px'}}>© 2026 YTECH SOLUTIONS | CASABLANCA</p>
      </footer>
    </Layout>
  );
}