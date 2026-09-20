"use client"

import React, { useState, useEffect, useRef } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { Mic, MicOff, Send, Volume2, VolumeX, ShieldAlert, Sparkles, Navigation, Search, Check, X } from "lucide-react"
import { useRouter } from "next/navigation"
import axios from "axios"

interface Message {
  id: string
  text: string
  sender: "user" | "assistant"
  timestamp: Date
  action?: string
  confidence?: number
}

type AssistantState = "idle" | "listening" | "processing" | "confirming" | "executing" | "speaking" | "error"

export default function AIAssistantPage() {
  const router = useRouter()
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      text: "Hello! I am your AI Assistant. You can speak or type to navigate schemes, learning modules, or connect with mentors. What would you like to do?",
      sender: "assistant",
      timestamp: new Date()
    }
  ])
  const [inputText, setInputText] = useState("")
  const [state, setState] = useState<AssistantState>("idle")
  const [isMuted, setIsMuted] = useState(false)
  const [recognition, setRecognition] = useState<any>(null)
  const [interimTranscript, setInterimTranscript] = useState("")
  const [pendingAction, setPendingAction] = useState<any>(null)

  const messagesEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // Scroll to bottom on new messages
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [messages])

  // Initialize Speech Recognition API
  useEffect(() => {
    if (typeof window !== "undefined") {
      const SpeechRecognition = (window as any).SpeechRecognition || (window as any).webkitSpeechRecognition
      if (SpeechRecognition) {
        const rec = new SpeechRecognition()
        rec.continuous = false
        rec.interimResults = true
        rec.lang = "en-US" // Fallback language

        rec.onstart = () => {
          setState("listening")
          setInterimTranscript("")
        }

        rec.onresult = (event: any) => {
          let interim = ""
          let final = ""
          for (let i = event.resultIndex; i < event.results.length; ++i) {
            if (event.results[i].isFinal) {
              final += event.results[i][0].transcript
            } else {
              interim += event.results[i][0].transcript
            }
          }
          setInterimTranscript(interim)
          if (final) {
            setInputText(final)
          }
        }

        rec.onerror = (event: any) => {
          if (event.error === "no-speech" || event.error === "aborted") {
            setState("idle")
            return
          }
          console.warn("Speech recognition issue:", event.error)
          setState("idle")
        }

        rec.onend = () => {
          setState((prev) => (prev === "listening" ? "idle" : prev))
        }

        setRecognition(rec)
      }
    }
  }, [])

  const toggleListening = () => {
    if (!recognition) {
      alert("Speech recognition is not supported in this browser.")
      return
    }

    if (state === "listening") {
      recognition.stop()
    } else {
      recognition.start()
    }
  }

  const speakResponse = (text: string) => {
    if (isMuted || typeof window === "undefined" || !window.speechSynthesis) {
      setState("idle")
      return
    }
    try {
      window.speechSynthesis.cancel()
      const utterance = new SpeechSynthesisUtterance(text)
      
      let timeoutId: any = null
      
      utterance.onstart = () => {
        setState("speaking")
        timeoutId = setTimeout(() => {
          setState("idle")
        }, 6000)
      }
      
      utterance.onend = () => {
        if (timeoutId) clearTimeout(timeoutId)
        setState("idle")
      }
      
      utterance.onerror = () => {
        if (timeoutId) clearTimeout(timeoutId)
        setState("idle")
      }
      
      window.speechSynthesis.speak(utterance)
    } catch (err) {
      console.error("Speech Synthesis failed", err)
      setState("idle")
    }
  }

  const handleSend = async (textToSend: string) => {
    const text = textToSend.trim()
    if (!text) return

    // Add user message
    const userMsgId = Math.random().toString()
    setMessages((prev) => [
      ...prev,
      { id: userMsgId, text, sender: "user", timestamp: new Date() }
    ])
    setInputText("")
    setState("processing")

    try {
      // Call local AI API route
      const response = await axios.post("/api/ai/voice-command", {
        query: text,
        currentLanguage: "en"
      })

      if (response.data.success) {
        const data = response.data.data
        handleVoiceAction(data)
      } else {
        handleFallback("Sorry, I encountered an issue processing that.")
      }
    } catch (error: any) {
      console.error("API Error:", error.response?.data || error.message);
      if (error.response?.data?.error) {
        handleFallback(`API Error: ${error.response.data.error}`);
        setState("idle");
      } else {
        // Offline fallback rules
        processOffline(text);
      }
    }
  }

  const processOffline = (text: string) => {
    const lower = text.toLowerCase()
    let path = ""
    let speech = ""

    if (lower.includes("scheme") || lower.includes("yojana") || lower.includes("योजना")) {
      path = "/dashboard/schemes"
      speech = "Navigating to government schemes offline."
    } else if (lower.includes("course") || lower.includes("learning") || lower.includes("study")) {
      path = "/dashboard/learning"
      speech = "Opening learning hub offline."
    } else if (lower.includes("mentor") || lower.includes("mentorship")) {
      path = "/dashboard/mentorship"
      speech = "Opening mentorship support offline."
    } else if (lower.includes("dashboard") || lower.includes("home")) {
      path = "/dashboard"
      speech = "Opening home dashboard."
    }

    if (path) {
      handleVoiceAction({
        action: "NAVIGATE",
        path,
        speechResponse: speech,
        confidence: 0.90
      })
    } else {
      handleFallback("You are offline. Try saying 'open schemes' or 'start learning'.")
    }
  }

  const handleVoiceAction = (actionPayload: any) => {
    const { action, path, speechResponse, confidence } = actionPayload

    if (confidence >= 0.80) {
      executeAction(actionPayload)
    } else if (confidence >= 0.50) {
      setState("confirming")
      setPendingAction(actionPayload)
      setMessages((prev) => [
        ...prev,
        {
          id: Math.random().toString(),
          text: `Did you mean: "${speechResponse}"?`,
          sender: "assistant",
          timestamp: new Date(),
          action: "CONFIRMATION"
        }
      ])
      speakResponse(`Did you mean: ${speechResponse}?`)
    } else {
      handleFallback(action === "UNKNOWN" ? speechResponse : "I did not get that. Try asking to open schemes or learning hub.")
    }
  }

  const executeAction = (actionPayload: any) => {
    const { action, path, speechResponse, searchQuery } = actionPayload
    setState("executing")

    setMessages((prev) => [
      ...prev,
      {
        id: Math.random().toString(),
        text: speechResponse,
        sender: "assistant",
        timestamp: new Date(),
        action
      }
    ])

    speakResponse(speechResponse)

    // Execute route navigation
    if (path) {
      setTimeout(() => {
        let route = path.startsWith("/dashboard") ? path : `/dashboard${path}`
        if (action === "SEARCH" && searchQuery) {
          route += `?search=${encodeURIComponent(searchQuery)}`
        }
        router.push(route)
      }, 1500)
    }
  }

  const handleFallback = (message: string) => {
    setMessages((prev) => [
      ...prev,
      { id: Math.random().toString(), text: message, sender: "assistant", timestamp: new Date() }
    ])
    speakResponse(message)
  }

  const confirmAction = (accept: boolean) => {
    if (accept && pendingAction) {
      executeAction(pendingAction)
    } else {
      setState("idle")
      handleFallback("Okay, what else can I help you with?")
    }
    setPendingAction(null)
  }

  return (
    <div className="flex-1 flex flex-col h-[calc(100vh-65px)] max-w-5xl mx-auto w-full p-4 md:p-6 space-y-6">
      
      {/* Header Info */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2">
            <Sparkles className="w-6 h-6 text-primary animate-pulse" />
            AI Voice Assistant
          </h1>
          <p className="text-sm text-muted-foreground">Ask to open schemes, search courses, or match mentors.</p>
        </div>
        <button
          onClick={() => setIsMuted(!isMuted)}
          className="p-2 rounded-full glass-card border border-white/10 hover:bg-white/5 transition-colors"
        >
          {isMuted ? <VolumeX className="w-5 h-5 text-destructive" /> : <Volume2 className="w-5 h-5 text-primary" />}
        </button>
      </div>

      {/* Main chat viewport */}
      <div className="flex-1 glass-card border border-white/10 rounded-2xl p-6 flex flex-col overflow-hidden relative min-h-[300px]">
        
        {/* State Indicators */}
        <div className="absolute top-4 right-6 flex items-center gap-2 z-10">
          <span className={`h-2.5 w-2.5 rounded-full ${
            state === "listening" ? "bg-red-500 animate-ping" : 
            state === "processing" ? "bg-orange-500 animate-pulse" : 
            state === "speaking" ? "bg-green-500" : "bg-blue-500"
          }`} />
          <span className="text-xs font-semibold capitalize text-muted-foreground">{state}</span>
        </div>

        {/* Chat Messages */}
        <div className="flex-1 overflow-y-auto space-y-4 pr-2 select-none">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${msg.sender === "user" ? "justify-end" : "justify-start"}`}
            >
              <div
                className={`max-w-[80%] p-4 rounded-2xl flex flex-col space-y-2 border ${
                  msg.sender === "user"
                    ? "bg-primary text-primary-foreground border-primary/20 rounded-br-none"
                    : "glass-card border-white/10 text-foreground rounded-bl-none"
                }`}
              >
                <span className="text-sm font-medium leading-relaxed">{msg.text}</span>
                {msg.action && msg.action !== "CONFIRMATION" && (
                  <span className="text-[10px] opacity-70 flex items-center gap-1">
                    <Navigation className="w-3 h-3" /> Action: {msg.action}
                  </span>
                )}
                {msg.action === "CONFIRMATION" && state === "confirming" && (
                  <div className="flex items-center gap-2 pt-2">
                    <button
                      onClick={() => confirmAction(false)}
                      className="flex items-center gap-1 px-3 py-1.5 rounded-lg bg-destructive/20 hover:bg-destructive/30 border border-destructive/30 text-destructive text-xs transition-colors"
                    >
                      <X className="w-3.5 h-3.5" /> No
                    </button>
                    <button
                      onClick={() => confirmAction(true)}
                      className="flex items-center gap-1 px-3 py-1.5 rounded-lg bg-green-500/20 hover:bg-green-500/30 border border-green-500/30 text-green-500 text-xs transition-colors"
                    >
                      <Check className="w-3.5 h-3.5" /> Yes
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))}
          {state === "listening" && interimTranscript && (
            <div className="flex justify-end">
              <div className="max-w-[80%] p-4 rounded-2xl bg-primary/40 text-primary-foreground/80 rounded-br-none border border-primary/10">
                <span className="text-sm font-medium leading-relaxed italic">{interimTranscript}...</span>
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>
      </div>

      {/* Voice Assistant Floating Micro Wave & Inputs */}
      <div className="flex items-center gap-4">
        
        {/* Mic Control button */}
        <button
          onClick={toggleListening}
          className={`h-14 w-14 rounded-full flex items-center justify-center border shadow-md transition-all duration-300 ${
            state === "listening"
              ? "bg-red-500 hover:bg-red-600 border-red-500/20 shadow-red-500/20"
              : "bg-primary hover:bg-primary/90 border-primary/20"
          }`}
        >
          {state === "listening" ? (
            <MicOff className="w-6 h-6 text-white" />
          ) : (
            <Mic className="w-6 h-6 text-white" />
          )}
        </button>

        {/* Text query input */}
        <div className="flex-1 flex gap-2 glass-card border border-white/10 rounded-full px-4 py-2 items-center">
          <input
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") handleSend(inputText)
            }}
            placeholder={state === "listening" ? "Listening to your voice..." : "Ask me anything..."}
            disabled={state === "listening" || state === "processing"}
            className="flex-1 bg-transparent border-0 outline-none text-sm text-foreground placeholder:text-muted-foreground"
          />
          <button
            onClick={() => handleSend(inputText)}
            disabled={!inputText.trim() || state === "listening" || state === "processing"}
            className="p-2 rounded-full bg-primary/10 hover:bg-primary/20 text-primary transition-colors disabled:opacity-50"
          >
            <Send className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  )
}
