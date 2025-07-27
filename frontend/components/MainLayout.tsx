'use client'

import React, { useState } from 'react'
import Header from './Header'
import SideNav from './SideNav'
import Footer from './Footer'
import ChatDrawer from './chat/ChatDrawer'

interface MainLayoutProps {
  children: React.ReactNode
}

export default function MainLayout({ children }: MainLayoutProps) {
  const [isSideNavOpen, setIsSideNavOpen] = useState(false)

  const handleMenuToggle = () => {
    setIsSideNavOpen(!isSideNavOpen)
  }

  const handleSideNavClose = () => {
    setIsSideNavOpen(false)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Header onMenuToggle={handleMenuToggle} />
      <SideNav isOpen={isSideNavOpen} onClose={handleSideNavClose} />
      
      <main className={`
        pt-12 pb-16 transition-all duration-300
        md:ml-64
      `}>
        <div className="p-4">
          {children}
        </div>
      </main>
      
      <Footer />
      <ChatDrawer />
    </div>
  )
}