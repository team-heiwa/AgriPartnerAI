'use client'

import React from 'react'

interface RiskCardProps {
  type: 'pest' | 'disease'
  score: number
  title: string
  icon: string
  onClick?: () => void
}

export default function RiskCard({ type, score, title, icon, onClick }: RiskCardProps) {
  const getRiskColor = (score: number) => {
    if (score >= 0.6) return 'risk-alert'
    if (score >= 0.4) return 'risk-watch'
    return 'risk-ok'
  }

  const getRiskLevel = (score: number) => {
    if (score >= 0.6) return 'HIGH'
    if (score >= 0.4) return 'MEDIUM'
    return 'LOW'
  }

  const riskColor = getRiskColor(score)
  const riskLevel = getRiskLevel(score)

  return (
    <div 
      className={`
        bg-white rounded-lg shadow-md p-4 cursor-pointer transition-all hover:shadow-lg
        border-l-4 border-${riskColor}
      `}
      onClick={onClick}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <span className="text-2xl">{icon}</span>
          <h3 className="font-semibold text-gray-800">{title}</h3>
        </div>
        <span className={`text-xs font-bold px-2 py-1 rounded text-white bg-${riskColor}`}>
          {riskLevel}
        </span>
      </div>
      
      <div className="space-y-2">
        <div className="flex justify-between items-center">
          <span className="text-sm text-gray-600">リスクスコア</span>
          <span className={`font-bold text-lg text-${riskColor}`}>
            {score.toFixed(2)}
          </span>
        </div>
        
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div 
            className={`h-2 rounded-full bg-${riskColor}`}
            style={{ width: `${score * 100}%` }}
          ></div>
        </div>
      </div>
    </div>
  )
}