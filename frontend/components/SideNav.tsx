'use client'

import React from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { MdDashboard, MdOutlineDescription } from 'react-icons/md'
import { FaVideo } from 'react-icons/fa'
import { TbDrone } from 'react-icons/tb'
import { HiLibrary, HiClipboardList } from 'react-icons/hi'

interface SideNavProps {
  isOpen: boolean
  onClose: () => void
}

const navItems: { id: string; label: string; icon: React.ElementType; href: string }[] = [
  { id: 'dashboard', label: 'Dashboard', icon: MdDashboard, href: '/' },
  { id: 'visit-recorder', label: 'Visit Recorder', icon: FaVideo, href: '/visit-recorder' },
  { id: 'library', label: 'Library', icon: HiLibrary, href: '/library' },
  { id: 'drone-ops', label: 'Drone Ops', icon: TbDrone, href: '/drone-ops' },
  { id: 'actions', label: 'Actions', icon: HiClipboardList, href: '/actions' },
  { id: 'reports', label: 'Reports', icon: MdOutlineDescription, href: '/reports' },
]

export default function SideNav({ isOpen, onClose }: SideNavProps) {
  const pathname = usePathname()

  return (
    <>
      {/* モバイル用オーバーレイ */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
          onClick={onClose}
        />
      )}
      
      {/* サイドナビゲーション */}
      <nav className={`
        fixed top-12 left-0 h-[calc(100vh-3rem)] w-64 bg-white border-r border-gray-200 z-40
        transform transition-transform duration-300 ease-in-out
        ${isOpen ? 'translate-x-0' : '-translate-x-full'}
        md:translate-x-0
      `}>
        <div className="p-4">
          <ul className="space-y-2">
            {navItems.map((item) => (
              <li key={item.id}>
                <Link
                  href={item.href}
                  onClick={onClose}
                  className={`
                    w-full flex items-center gap-3 px-3 py-2 rounded-lg transition-colors
                    ${pathname === item.href
                      ? 'bg-blue-50 text-blue-700 border border-blue-200' 
                      : 'hover:bg-gray-50 text-gray-700'
                    }
                  `}
                >
                  {(() => {
                    const Icon = item.icon
                    return <Icon className="text-lg" />
                  })()}
                  <span className="font-medium">{item.label}</span>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </nav>
    </>
  )
}