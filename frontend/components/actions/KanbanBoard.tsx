'use client'

import React, { useState } from 'react'

interface Action {
  id: string
  title: string
  description: string
  priority: 'high' | 'medium' | 'low'
  assignee: string
  dueDate: Date
  tags: string[]
  relatedCard?: string
  status: 'todo' | 'in_progress' | 'review' | 'done'
  estimatedTime: number // minutes
  actualTime?: number // minutes
}

interface KanbanBoardProps {
  onActionSelect: (actionId: string) => void
  onVoiceMemo: (actionId: string) => void
  selectedAction: string | null
}

export default function KanbanBoard({ onActionSelect, onVoiceMemo, selectedAction }: KanbanBoardProps) {
  const [actions, setActions] = useState<Action[]>([
    {
      id: '1',
      title: '換気30%減少',
      description: '灰色かび病対策として換気を30%減少させる',
      priority: 'high',
      assignee: '田中農場長',
      dueDate: new Date('2024-01-16T10:00:00'),
      tags: ['#換気制御', '#病気対策'],
      relatedCard: 'card_014',
      status: 'todo',
      estimatedTime: 30
    },
    {
      id: '2',
      title: '葉面乾燥促進',
      description: '加温設備を使用して葉面乾燥を促進',
      priority: 'high',
      assignee: '佐藤作業員',
      dueDate: new Date('2024-01-16T14:00:00'),
      tags: ['#加温', '#乾燥促進'],
      relatedCard: 'card_014',
      status: 'todo',
      estimatedTime: 45
    },
    {
      id: '3',
      title: 'カメムシ防除薬剤散布',
      description: '東エリアB-3でカメムシ防除薬剤を散布',
      priority: 'high',
      assignee: '鈴木作業員',
      dueDate: new Date('2024-01-15T16:00:00'),
      tags: ['#薬剤散布', '#害虫防除'],
      relatedCard: 'card_015',
      status: 'in_progress',
      estimatedTime: 60,
      actualTime: 35
    },
    {
      id: '4',
      title: '湿度センサー校正',
      description: '西エリアの湿度センサー値を校正',
      priority: 'medium',
      assignee: '山田技術者',
      dueDate: new Date('2024-01-17T09:00:00'),
      tags: ['#センサー', '#メンテナンス'],
      status: 'review',
      estimatedTime: 90,
      actualTime: 75
    },
    {
      id: '5',
      title: '草刈り実施',
      description: '南エリア全体の草刈り作業',
      priority: 'low',
      assignee: '田中農場長',
      dueDate: new Date('2024-01-14T08:00:00'),
      tags: ['#草刈り', '#メンテナンス'],
      relatedCard: 'card_010',
      status: 'done',
      estimatedTime: 120,
      actualTime: 110
    }
  ])

  const columns = [
    { id: 'todo', title: 'To Do', color: 'bg-blue-50 border-blue-200', count: actions.filter(a => a.status === 'todo').length },
    { id: 'in_progress', title: 'In Progress', color: 'bg-yellow-50 border-yellow-200', count: actions.filter(a => a.status === 'in_progress').length },
    { id: 'review', title: 'Review', color: 'bg-purple-50 border-purple-200', count: actions.filter(a => a.status === 'review').length },
    { id: 'done', title: 'Done', color: 'bg-green-50 border-green-200', count: actions.filter(a => a.status === 'done').length }
  ]

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'border-l-4 border-risk-alert'
      case 'medium': return 'border-l-4 border-risk-watch'
      case 'low': return 'border-l-4 border-risk-ok'
      default: return 'border-l-4 border-gray-300'
    }
  }

  const getPriorityLabel = (priority: string) => {
    switch (priority) {
      case 'high': return '🔴 高'
      case 'medium': return '🟡 中'
      case 'low': return '🟢 低'
      default: return priority
    }
  }

  const formatDueDate = (date: Date) => {
    const now = new Date()
    const diffMs = date.getTime() - now.getTime()
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    
    if (diffDays < 0) {
      return `${Math.abs(diffDays)}日遅れ`
    } else if (diffDays === 0) {
      return '今日'
    } else if (diffDays === 1) {
      return '明日'
    } else {
      return `${diffDays}日後`
    }
  }

  const getDueDateColor = (date: Date) => {
    const now = new Date()
    const diffMs = date.getTime() - now.getTime()
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    
    if (diffDays < 0) return 'text-red-600 bg-red-50'
    if (diffDays === 0) return 'text-orange-600 bg-orange-50'
    if (diffDays <= 1) return 'text-yellow-600 bg-yellow-50'
    return 'text-gray-600 bg-gray-50'
  }

  const moveAction = (actionId: string, newStatus: 'todo' | 'in_progress' | 'review' | 'done') => {
    setActions(prev => prev.map(action => 
      action.id === actionId ? { ...action, status: newStatus } : action
    ))
  }

  const handleDragStart = (e: React.DragEvent, actionId: string) => {
    e.dataTransfer.setData('text/plain', actionId)
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
  }

  const handleDrop = (e: React.DragEvent, columnId: string) => {
    e.preventDefault()
    const actionId = e.dataTransfer.getData('text/plain')
    moveAction(actionId, columnId as 'todo' | 'in_progress' | 'review' | 'done')
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {columns.map((column) => (
          <div
            key={column.id}
            className={`${column.color} rounded-lg border-2 border-dashed min-h-[400px]`}
            onDragOver={handleDragOver}
            onDrop={(e) => handleDrop(e, column.id)}
          >
            {/* カラムヘッダー */}
            <div className="p-4 border-b border-gray-200 bg-white rounded-t-lg">
              <div className="flex items-center justify-between">
                <h3 className="font-semibold text-gray-800">{column.title}</h3>
                <span className="bg-gray-200 text-gray-700 text-xs px-2 py-1 rounded-full">
                  {column.count}
                </span>
              </div>
            </div>

            {/* アクションカード */}
            <div className="p-2 space-y-3">
              {actions
                .filter(action => action.status === column.id)
                .map((action) => (
                  <div
                    key={action.id}
                    draggable
                    onDragStart={(e) => handleDragStart(e, action.id)}
                    onClick={() => onActionSelect(action.id)}
                    className={`
                      bg-white rounded-lg p-3 shadow-sm cursor-pointer transition-all hover:shadow-md
                      ${getPriorityColor(action.priority)}
                      ${selectedAction === action.id ? 'ring-2 ring-blue-500' : ''}
                    `}
                  >
                    <div className="space-y-2">
                      {/* タイトルと優先度 */}
                      <div className="flex items-start justify-between">
                        <h4 className="font-medium text-sm text-gray-800 line-clamp-2">
                          {action.title}
                        </h4>
                        <span className="text-xs whitespace-nowrap ml-2">
                          {getPriorityLabel(action.priority)}
                        </span>
                      </div>

                      {/* 説明 */}
                      <p className="text-xs text-gray-600 line-clamp-2">
                        {action.description}
                      </p>

                      {/* 担当者と期限 */}
                      <div className="flex items-center justify-between text-xs">
                        <span className="text-gray-600">👤 {action.assignee}</span>
                        <span className={`px-2 py-1 rounded ${getDueDateColor(action.dueDate)}`}>
                          {formatDueDate(action.dueDate)}
                        </span>
                      </div>

                      {/* タグ */}
                      {action.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {action.tags.slice(0, 2).map((tag, index) => (
                            <span
                              key={index}
                              className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded"
                            >
                              {tag}
                            </span>
                          ))}
                          {action.tags.length > 2 && (
                            <span className="text-xs text-gray-500">+{action.tags.length - 2}</span>
                          )}
                        </div>
                      )}

                      {/* 進捗と時間 */}
                      <div className="flex items-center justify-between text-xs text-gray-500">
                        <div className="flex items-center gap-2">
                          {action.relatedCard && (
                            <span>🔗 {action.relatedCard}</span>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <span>⏱️</span>
                          {action.actualTime ? (
                            <span>{action.actualTime}/{action.estimatedTime}分</span>
                          ) : (
                            <span>{action.estimatedTime}分</span>
                          )}
                        </div>
                      </div>

                      {/* アクションボタン */}
                      <div className="flex gap-1 pt-2 border-t border-gray-100">
                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            onVoiceMemo(action.id)
                          }}
                          className="flex-1 text-xs bg-gray-100 hover:bg-gray-200 px-2 py-1 rounded transition-colors"
                        >
                          🎤 メモ
                        </button>
                        {action.status !== 'done' && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation()
                              const nextStatus = action.status === 'todo' ? 'in_progress' : 
                                               action.status === 'in_progress' ? 'review' : 'done'
                              moveAction(action.id, nextStatus)
                            }}
                            className="flex-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-800 px-2 py-1 rounded transition-colors"
                          >
                            {action.status === 'todo' ? '▶️ 開始' : 
                             action.status === 'in_progress' ? '👀 確認' : '✅ 完了'}
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))}

              {/* 新規追加ボタン */}
              {column.id === 'todo' && (
                <button className="w-full border-2 border-dashed border-gray-300 rounded-lg p-3 text-center text-gray-500 hover:border-gray-400 hover:text-gray-600 transition-colors">
                  ➕ アクション追加
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* 統計サマリー */}
      <div className="mt-6 pt-6 border-t border-gray-200">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
          <div>
            <div className="text-lg font-bold text-blue-600">{actions.filter(a => a.status === 'todo').length}</div>
            <div className="text-xs text-gray-600">未着手</div>
          </div>
          <div>
            <div className="text-lg font-bold text-yellow-600">{actions.filter(a => a.status === 'in_progress').length}</div>
            <div className="text-xs text-gray-600">進行中</div>
          </div>
          <div>
            <div className="text-lg font-bold text-purple-600">{actions.filter(a => a.status === 'review').length}</div>
            <div className="text-xs text-gray-600">確認中</div>
          </div>
          <div>
            <div className="text-lg font-bold text-green-600">{actions.filter(a => a.status === 'done').length}</div>
            <div className="text-xs text-gray-600">完了</div>
          </div>
        </div>
      </div>
    </div>
  )
}