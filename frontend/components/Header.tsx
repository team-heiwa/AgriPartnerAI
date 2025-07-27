'use client'

import React, { useState } from 'react'
import { MdNotifications } from 'react-icons/md'
import { FiMenu } from 'react-icons/fi'
import { TbDrone } from 'react-icons/tb'

interface HeaderProps {
  onMenuToggle: () => void
}

export default function Header({ onMenuToggle }: HeaderProps) {
  const [droneStatus, setDroneStatus] = useState<'online' | 'offline'>('online')
  const [alerts, setAlerts] = useState(3)

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-white border-b border-gray-200 h-12">
      <div className="flex items-center justify-between h-full px-4">
        <div className="flex items-center gap-4">
          <h1 className="text-lg font-bold text-gray-800">Agri Partner AI</h1>
        </div>
        
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <span className="text-sm flex items-center gap-1">
              <TbDrone /> Drone
            </span>
            <div className={`w-2 h-2 rounded-full ${droneStatus === 'online' ? 'bg-risk-ok' : 'bg-risk-alert'}`}></div>
          </div>
          
          <div className="relative">
            <button className="flex items-center gap-1 text-sm hover:bg-gray-100 px-2 py-1 rounded">
              <MdNotifications />
              <span>Alert</span>
              {alerts > 0 && (
                <span className="bg-risk-alert text-white text-xs rounded-full px-1.5 py-0.5 min-w-[1.25rem] text-center">
                  {alerts}
                </span>
              )}
            </button>
          </div>
          
          <button 
            onClick={onMenuToggle}
            className="md:hidden p-2 hover:bg-gray-100 rounded"
          >
            <FiMenu className="text-lg" />
          </button>
        </div>
      </div>
    </header>
  )
}